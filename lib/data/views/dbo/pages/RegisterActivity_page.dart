import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:senior/data/global_data.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/button_components.dart';

class RegisterActivityPage extends StatefulWidget {
  final List<dynamic> dados;
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

  // Variáveis para mostrar resultado do cálculo
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
            content: Text("Hora final não pode ser antes da inicial!")),
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

      // Verifica se horímetro final <= inicial
      _horimetroError = horimetroInicial != null &&
          horimetroFinal != null &&
          horimetroFinal <= horimetroInicial;
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

      if (!_dados.contains(combinedData)) {
        setState(() {
          _dados.add(combinedData);
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

  /// Mesma aparência dos TextFields do RegisterPublicDBO
  Widget _buildTextField(
      String label, TextEditingController controller, String hint) {
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

  /// Exibe cada motivo de parada com cartão estilizado
  Widget _buildMotivoParadaItem(MotivoParada parada) {
    final duracaoMin = parada.duracao.inMinutes;
    final h = duracaoMin ~/ 60;
    final m = duracaoMin % 60;
    final tempoParada = (h > 0) ? '$h h $m min' : '$m min';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(parada.descricao),
        subtitle: Text(
          'Início: ${_dateTimeFormat.format(parada.inicio)}\n'
          'Fim: ${_dateTimeFormat.format(parada.fim)}\n'
          'Tempo parado: $tempoParada',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No RegisterPublicDBO, não há cor de fundo explícita; mas se quiser igual:
      // backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text(
          'Cadastro de Atividades',
          style: TextStyle(color: Colors.white),
        ),
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
                // Campos de texto com o estilo do RegisterPublicDBO
                _buildTextField(
                    "Patrimônio", _patrimonioController, "Digite o Patrimônio"),
                _buildTextField("Patrimônio Implemento",
                    _patrimonioImplementoController, "Digite o Patrimônio"),
                _buildTextField(
                    "Maquina", _maquinaController, "Digite o Patrimônio"),
                _buildTextField(
                    "Operação", _operacaoController, "Digite a Operação"),

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

                // Lista de motivos já adicionados
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
                // Botões de data/hora
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _selecionarHorario(context, true),
                        child: Text(
                          _horarioInicial ?? "Selecionar Hora Inicial",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _selecionarHorario(context, false),
                        child: Text(
                          _horarioFinal ?? "Selecionar Hora Final",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Erros
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
                if (_horimetroError)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '⚠ Horímetro Final deve ser maior que o Inicial!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Mostra resultados de horas e horímetro
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
                // Botão final no estilo do RegisterPublicDBO
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
