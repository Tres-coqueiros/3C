import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:senior/data/global_data.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/button_components.dart';

class RegisterActivityPage extends StatefulWidget {
  final List<dynamic>
      dados; // Normalmente é a mesma referência de listaDeRegistros
  final Map<String, dynamic> informacoesGerais;

  const RegisterActivityPage({
    Key? key,
    required this.dados,
    required this.informacoesGerais,
    required Map<String, Object?> atividade,
  }) : super(key: key);

  @override
  State<RegisterActivityPage> createState() => _RegisterActivityPageState();
}

// Modelo simples para guardar cada "Motivo de Parada"
class MotivoParada {
  final String descricao;
  final DateTime inicio;
  final DateTime fim;

  MotivoParada({
    required this.descricao,
    required this.inicio,
    required this.fim,
  });

  Duration get duracao => fim.difference(inicio);
}

class _RegisterActivityPageState extends State<RegisterActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  late List<dynamic> _dados;
  late Map<String, dynamic> _informacoesGerais;

  // Controllers
  final TextEditingController _patrimonioController = TextEditingController();
  final TextEditingController _patrimonioImplementoController =
      TextEditingController();
  final TextEditingController _maquinaController = TextEditingController();
  final TextEditingController _operacaoController = TextEditingController();
  final TextEditingController _areaTrabalhadaController =
      TextEditingController();
  final TextEditingController _motivoTempController = TextEditingController();
  final TextEditingController _talhaoController = TextEditingController();
  final TextEditingController _culturaController = TextEditingController();
  final TextEditingController _horimetroInicialController =
      TextEditingController();
  final TextEditingController _horimetroFinalController =
      TextEditingController();

  String? _horarioInicial;
  String? _horarioFinal;
  bool _horaRangeError = false;
  bool _horimetroError = false;
  String? _horimetroErrorMessage;

  // Exibição de horas trabalhadas e diferença de horímetro
  String _tempoTrabalhado = '';
  String _horimetroTotal = '';

  // Lista de motivos de parada
  final List<MotivoParada> _motivosParada = [];

  @override
  void initState() {
    super.initState();
    _dados = widget.dados;
    _informacoesGerais = widget.informacoesGerais;

    // Caso venha horário da tela anterior
    _horarioInicial = _informacoesGerais['horarioInicial'];
    _horarioFinal = _informacoesGerais['horarioFinal'];
  }

  // Exibe um DateTimePicker e retorna o valor escolhido
  Future<DateTime?> _pickDateTime() async {
    DateTime? selecionado;
    await DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onConfirm: (date) {
        selecionado = date;
      },
      currentTime: DateTime.now(),
      locale: LocaleType.pt,
    );
    return selecionado;
  }

  // Adiciona motivo de parada (com início e fim)
  Future<void> _addMotivoParada() async {
    final descricao = _motivoTempController.text.trim();
    if (descricao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Digite o motivo de parada antes de adicionar!"),
        ),
      );
      return;
    }

    final inicio = await _pickDateTime();
    if (inicio == null) return;

    final fim = await _pickDateTime();
    if (fim == null) return;

    if (fim.isBefore(inicio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hora final não pode ser antes da inicial!"),
        ),
      );
      return;
    }

    final parada = MotivoParada(descricao: descricao, inicio: inicio, fim: fim);
    setState(() {
      _motivosParada.add(parada);
      _motivoTempController.clear();
    });
  }

  // Seleciona data/hora para horário inicial ou final da atividade
  void _selecionarHorario(BuildContext context, bool isInicial) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onConfirm: (date) {
        setState(() {
          final formatted = _dateTimeFormat.format(date);
          if (isInicial) {
            _horarioInicial = formatted;
          } else {
            _horarioFinal = formatted;
          }
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.pt,
    );
  }

  // Valida e salva a atividade
  void _handleAdicionar() {
    final horimetroInicial = double.tryParse(_horimetroInicialController.text);
    final horimetroFinal = double.tryParse(_horimetroFinalController.text);

    setState(() {
      // Verifica se horário final é antes do inicial
      _horaRangeError = _horarioInicial != null &&
          _horarioFinal != null &&
          _dateTimeFormat.parse(_horarioFinal!).isBefore(
                _dateTimeFormat.parse(_horarioInicial!),
              );

      // Verifica as condições de erro para horímetro
      if (horimetroInicial != null && horimetroFinal != null) {
        if (horimetroFinal <= horimetroInicial) {
          _horimetroError = true;
          _horimetroErrorMessage =
              '⚠ Horímetro Final deve ser maior que o Inicial!';
        } else if ((horimetroFinal - horimetroInicial) > 12) {
          _horimetroError = true;
          _horimetroErrorMessage =
              '⚠ Horímetro excede as 12 horas de trabalho!';
        } else {
          _horimetroError = false;
          _horimetroErrorMessage = null;
        }
      } else {
        // Se não conseguiu converter, não marcamos erro específico
        _horimetroError = false;
        _horimetroErrorMessage = null;
      }
    });

    if (_formKey.currentState!.validate() &&
        !_horaRangeError &&
        !_horimetroError) {
      // Calcula tempo total de horas
      String tempoTrabalhado = '';
      if (_horarioInicial != null && _horarioFinal != null) {
        final inicio = _dateTimeFormat.parse(_horarioInicial!);
        final fim = _dateTimeFormat.parse(_horarioFinal!);
        final duracao = fim.difference(inicio);
        final horas = duracao.inHours;
        final minutos = duracao.inMinutes % 60;
        tempoTrabalhado = horas > 0 ? '$horas h $minutos min' : '$minutos min';
      }

      // Calcula diferença de horímetro
      String horimetroTotal = '';
      if (horimetroInicial != null && horimetroFinal != null) {
        final dif = horimetroFinal - horimetroInicial;
        horimetroTotal = dif.toStringAsFixed(2);
      }

      setState(() {
        _tempoTrabalhado = tempoTrabalhado;
        _horimetroTotal = horimetroTotal;
      });

      // Monta map final
      final combinedData = {
        ..._informacoesGerais,
        'patrimonio': _patrimonioController.text,
        'patrimonioImplemento': _patrimonioImplementoController.text.isNotEmpty
            ? _patrimonioImplementoController.text
            : 'Não informado',
        'maquina': _maquinaController.text,
        'operacao': _operacaoController.text,
        'areaTrabalhada': _areaTrabalhadaController.text,
        'motivosParada': _motivosParada.map((p) {
          return {
            'descricao': p.descricao,
            'inicio': _dateTimeFormat.format(p.inicio),
            'fim': _dateTimeFormat.format(p.fim),
            'duracaoMin': p.duracao.inMinutes,
          };
        }).toList(),
        'talhao': _talhaoController.text,
        'cultura': _culturaController.text,
        'horaInicial': _horarioInicial ?? 'Não informado',
        'horaFinal': _horarioFinal ?? 'Não informado',
        'horimetroInicial': _horimetroInicialController.text,
        'horimetroFinal': _horimetroFinalController.text,
        'tempoTrabalhado': tempoTrabalhado,
        'horimetroTotal': horimetroTotal,
      };

      if (!listaDeRegistros.contains(combinedData)) {
        setState(() {
          listaDeRegistros.add(combinedData);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          duration: Duration(seconds: 1),
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
  }

  /// Mantém a aparência dos TextFields do RegisterPublicDBO
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? "Campo obrigatório" : null,
      ),
    );
  }

  /// Layout mais organizado para cada Motivo de Parada
  Widget _buildMotivoParadaItem(MotivoParada parada) {
    final duracaoMin = parada.duracao.inMinutes;
    final h = duracaoMin ~/ 60;
    final m = duracaoMin % 60;
    final tempoParada = (h > 0) ? '$h h $m min' : '$m min';

    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade600, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título do motivo
            Text(
              'Motivo: ${parada.descricao}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),

            // Início
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'Início: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: _dateTimeFormat.format(parada.inicio),
                  ),
                ],
              ),
            ),

            // Fim
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'Fim: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: _dateTimeFormat.format(parada.fim),
                  ),
                ],
              ),
            ),

            // Tempo parado
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'Tempo parado: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: tempoParada,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar para navegar e acessar histórico
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text('Cadastro de Atividades',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/detailsregister'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                    "Patrimônio", _patrimonioController, "Digite o Patrimônio"),
                _buildTextField("Patrimônio Implemento",
                    _patrimonioImplementoController, "Digite o Patrimônio"),
                _buildTextField(
                    "Maquina", _maquinaController, "Digite o Patrimônio"),
                _buildTextField(
                    "Operação", _operacaoController, "Digite a Operação"),
                _buildTextField("Área Trabalhada", _areaTrabalhadaController,
                    "Digite a área trabalhada (ex: 10 ha)"),

                // Linha "Motivo de Parada" + botão (+)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _motivoTempController,
                        decoration: InputDecoration(
                          labelText: "Motivo de Parada",
                          hintText: "Ex: Falta de material",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add,
                            size: 30, color: Colors.green),
                        onPressed: _addMotivoParada,
                      ),
                    ),
                  ],
                ),

                if (_motivosParada.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Motivos de Parada adicionados:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _motivosParada.length,
                          itemBuilder: (context, index) {
                            return _buildMotivoParadaItem(
                                _motivosParada[index]);
                          },
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),
                // Horímetro
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        "Horímetro Inicial",
                        _horimetroInicialController,
                        "Digite o Horímetro",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        "Horímetro Final",
                        _horimetroFinalController,
                        "Digite o Horímetro",
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                // Mensagens de erro
                if (_horaRangeError)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '⚠ Horário Final não pode ser menor que o Inicial!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (_horimetroError && _horimetroErrorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _horimetroErrorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                if (_tempoTrabalhado.isNotEmpty || _horimetroTotal.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        if (_tempoTrabalhado.isNotEmpty)
                          Text(
                            "Total Horas: $_tempoTrabalhado",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(width: 16),
                        if (_horimetroTotal.isNotEmpty)
                          Text(
                            "Dif. Horímetro: $_horimetroTotal",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),
                // Botão final
                Center(
                  child: ButtonComponents(
                    onPressed: _handleAdicionar,
                    text: 'Adicionar Atividade',
                    textColor: AppColorsComponents.hashours,
                    backgroundColor: AppColorsComponents.primary,
                    fontSize: 16,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 30,
                    ),
                    textAlign: Alignment.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
