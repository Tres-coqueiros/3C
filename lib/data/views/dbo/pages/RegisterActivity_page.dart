import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/global_data.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/button_components.dart';
import 'package:senior/data/views/widgets/components/search_components.dart';

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

class Patrimonio {
  final int bensId;
  final String bens;
  final String bensImple;
  final String Unidade;

  Patrimonio({
    required this.bensId,
    required this.bens,
    required this.bensImple,
    required this.Unidade,
  });
}

class _RegisterActivityPageState extends State<RegisterActivityPage> {
  final GetServices getServices = GetServices();
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  late Map<String, dynamic> _informacoesGerais;

  // Controllers
  final TextEditingController _patrimonioController = TextEditingController();
  final TextEditingController _patrimonioImplementoController =
      TextEditingController();
  final TextEditingController _descricaoPatrimonioController =
      TextEditingController(); // NOVO campo
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
      TextEditingController(); // Permitir vazio

  String? _horarioInicial;
  String? _horarioFinal;

  bool _horaRangeError = false;
  bool _horimetroError = false;
  String? _horimetroErrorMessage;

  String _tempoTrabalhado = '';
  String _horimetroTotal = '';

  // Lista de motivos de parada
  final List<MotivoParada> _motivosParada = [];

  // Lista de patrimônios (máquinas) buscados do backend
  List<Patrimonio> getPatrimonio = [];

  @override
  void initState() {
    super.initState();
    fetchPatrimonio();
    _informacoesGerais = widget.informacoesGerais;
    _horarioInicial = _informacoesGerais['horarioInicial'];
    _horarioFinal = _informacoesGerais['horarioFinal'];
  }

  void fetchPatrimonio() async {
    try {
      final result = await getServices.getMaquina();
      setState(() {
        getPatrimonio = result.map((patrimonio) {
          return Patrimonio(
            bensId: patrimonio['bensId'] ?? 0,
            bens: patrimonio['bens'] ?? '',
            bensImple: patrimonio['bensImple'] ?? '',
            Unidade: patrimonio['Unidade'] ?? '',
          );
        }).toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao buscar patrimônio"),
        ),
      );
    }
  }

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

  // Adiciona motivo de parada
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

  // Seleciona data/hora para horário inicial/final
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

      // Se horímetro final estiver preenchido, validamos
      if (horimetroFinal != null && horimetroInicial != null) {
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
        // Se Horímetro Final não foi preenchido, não gera erro
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
        'descricaoPatrimonio': _descricaoPatrimonioController.text.isNotEmpty
            ? _descricaoPatrimonioController.text
            : 'Não informado', // NOVO campo
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
        'horimetroFinal': _horimetroFinalController.text, // Pode ficar vazio
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Não definimos appBar para manter coerência com a tela anterior
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown p/ selecionar Patrimônio
                SearchableDropdown(
                  items: getPatrimonio,
                  itemLabel: (patrimonio) => patrimonio.bens,
                  onItemSelected: (patrimonio) {
                    setState(() {
                      _patrimonioController.text = patrimonio.bens;
                      _maquinaController.text = patrimonio.bensImple;
                    });
                  },
                ),

                // 1) Maquina
                _buildTextField(
                  "Maquina",
                  _maquinaController,
                  "Digite o Patrimônio",
                ),

                // 2) Patrimônio Implemento
                _buildTextField(
                  "Patrimônio Implemento",
                  _patrimonioImplementoController,
                  "Digite o Patrimônio",
                ),

                // 3) Descrição Patrimônio (NOVO campo)
                _buildTextField(
                  "Descrição Patrimônio",
                  _descricaoPatrimonioController,
                  "Digite a descrição do patrimônio",
                ),

                // Operação
                _buildTextField(
                  "Operação",
                  _operacaoController,
                  "Digite a Operação",
                ),

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
                      // Horímetro Final pode ficar vazio
                      child: _buildTextField(
                        "Horímetro Final",
                        _horimetroFinalController,
                        "Digite o Horímetro (opcional)",
                        isHorimetroFinal: true, // extra param
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
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

  // Campo de texto genérico
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool isHorimetroFinal = false,
  }) {
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
        // Se for Horímetro Final, não exigimos "Campo obrigatório"
        validator: (value) {
          if (!isHorimetroFinal && (value == null || value.isEmpty)) {
            return "Campo obrigatório";
          }
          return null; // se horímetro final estiver vazio, passa
        },
      ),
    );
  }

  // Motivo de parada item
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

            Text(
              'Início: ${_dateTimeFormat.format(parada.inicio)}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Fim: ${_dateTimeFormat.format(parada.fim)}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Tempo parado: $tempoParada',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
