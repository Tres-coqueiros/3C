import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:senior/data/core/interface/app_interface.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/global_data.dart';
import 'package:senior/data/views/dbo/pages/RegisterActivity_page.dart';
import 'package:senior/data/views/widgets/base_layout.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/button_components.dart';
import 'package:senior/data/views/widgets/components/search_components.dart';

class RegisterPublicDBO extends StatefulWidget {
  @override
  _RegisterPublicDBOState createState() => _RegisterPublicDBOState();
}

class _RegisterPublicDBOState extends State<RegisterPublicDBO> {
  final GetServices getServices = GetServices();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController safraController = TextEditingController();
  final TextEditingController talhaoController = TextEditingController();
  final TextEditingController culturaController = TextEditingController();
  final TextEditingController fazendaController = TextEditingController();
  final TextEditingController matriculaController = TextEditingController();
  final TextEditingController cicloController = TextEditingController();
  final TextEditingController aretalhaoController = TextEditingController();
  final TextEditingController areaTrabalhadaController =
      TextEditingController();

  String? _horarioInicial;
  String? _horarioFinal;
  Operador? operadorSelecionado;
  int? safraSelecionada;
  int? talhaoSelecionado;
  int? culturaSelecionada;
  int? fazendaSelecionada;
  String? cicloSelecionada;

  bool _horarioError = false;
  bool _horimetroError = false;
  List<Map<String, dynamic>> getOperacao = [];
  List<Operador> getOperador = [];

  @override
  void initState() {
    super.initState();
    fetchOperacao();
    fetchOperador();
  }

  void fetchOperacao() async {
    try {
      final result = await getServices.getOperacao();
      setState(() {
        getOperacao = result;
      });
      print("RESULT: $result");
    } catch (error) {
      print('Error em buscar todas as operações: $error');
    }
  }

  void fetchOperador() async {
    try {
      final result = await getServices.getOperador();
      setState(() {
        getOperador = result
            .map((data) => Operador(Codigo: data['Codigo'], Nome: data['Nome']))
            .toList();
      });
    } catch (error) {
      print('Erro ao buscar talhoes: $error');
    }
  }

  List<Map<String, dynamic>> getTalhoesBySafra(int safraId) {
    return getOperacao
        .where((op) => op['safraId'] == safraId)
        .map((op) => {'Talhao': op['Talhao']})
        .toList();
  }

  List<Map<String, dynamic>> getCiclosBySafra(int safraId) {
    return getOperacao
        .where((op) => op['safraId'] == safraId)
        .map((op) => {
              'cicloId': op['cicloId'],
              'Cicloprod': op['Cicloprod'],
              'cultura': op['cultura'],
            })
        .toList();
  }

  List<Map<String, dynamic>> getTalhaoBySafra(int safraId) {
    return getOperacao
        .where((op) => op['safraId'] == safraId)
        .map((op) => {
              'talhaoId': op['talhaoId'],
              'Talhao': op['Talhao'],
              'area': op['area']
            })
        .toList();
  }

  List<Map<String, dynamic>> getUniqueSafras() {
    final seen = <int>{};
    final List<Map<String, dynamic>> safraList = [];

    for (final op in getOperacao) {
      final sid = op['safraId'] as int?;
      if (sid != null && !seen.contains(sid)) {
        seen.add(sid);
        safraList.add({
          'safraId': op['safraId'],
          'Safra': op['Safra'],
          'Fazenda': op['Fazenda'],
        });
      }
    }
    return safraList;
  }

  void _selecionarHorario(BuildContext context, bool isInicial) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onConfirm: (date) {
        setState(() {
          String formatted = DateFormat('dd/MM/yyyy HH:mm').format(date);
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

  void _salvarRegistro() {
    setState(() {
      _horarioError = _horarioInicial == null || _horarioFinal == null;
    });

    if (_formKey.currentState!.validate() &&
        !_horarioError &&
        !_horimetroError) {
      final registro = {
        'matricula': matriculaController.text,
        'horarioInicial': _horarioInicial,
        'horarioFinal': _horarioFinal,
        'operacoes': [],
      };

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BaseLayout(
                  body: RegisterActivityPage(
                    dados: listaDeRegistros,
                    informacoesGerais: registro,
                    atividade: registro,
                  ),
                )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchableDropdown(
                  items: getOperador,
                  itemLabel: (operador) => operador.Nome,
                  onItemSelected: (operador) {
                    setState(() {
                      operadorSelecionado = operador;
                    });
                  },
                  labelText: "Operador",
                  hintText: "Selecione o operador",
                ),
                const SizedBox(height: 8),
                SearchableDropdown(
                  items: getUniqueSafras(),
                  itemLabel: (safra) => safra['Safra'], // "Safra 2023"
                  onItemSelected: (safra) {
                    setState(() {
                      safraSelecionada = safra['safraId'];
                      fazendaController.text =
                          safra['Fazenda']?.toString() ?? '';
                      culturaController.text =
                          safra['cultura']?.toString() ?? '';
                      // se quiser exibir a area dessa safra, etc.
                    });
                  },
                  labelText: "Safra",
                  hintText: "Selecione a safra",
                ),
                const SizedBox(height: 8),
                SearchableDropdown(
                  items: getCiclosBySafra(safraSelecionada ?? 0),
                  itemLabel: (ciclo) => ciclo['Cicloprod'], // "Ciclo Verão"
                  onItemSelected: (ciclo) {
                    setState(() {
                      cicloSelecionada = ciclo['cicloId']?.toString() ?? '';
                      cicloController.text = ciclo['Cicloprod'] ?? '';
                      culturaController.text = ciclo['cultura'] ?? '';
                      areaTrabalhadaController.text =
                          ciclo['area']?.toString() ?? '';
                    });
                  },
                  labelText: "Ciclo",
                  hintText: "Selecione o ciclo",
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  "Cultura",
                  culturaController,
                  "Cultura",
                  readOnly: true,
                ),
                _buildTextField(
                  "Fazenda",
                  fazendaController,
                  "Fazenda",
                  readOnly: true,
                ),
                const SizedBox(height: 8),
                SearchableDropdown(
                  items: getTalhoesBySafra(safraSelecionada ?? 0),
                  itemLabel: (talhao) => talhao['Talhao'],
                  onItemSelected: (talhao) {
                    setState(() {
                      talhaoSelecionado = talhao['talhaoId'];
                      talhaoController.text =
                          talhao['Talhao']?.toString() ?? '';
                      print(talhao['area']?.toString());
                      aretalhaoController.text =
                          talhao['area']?.toString() ?? '';
                    });
                  },
                  labelText: "Talhão",
                  hintText: "Selecione o talhão",
                ),
                const SizedBox(height: 8),
                _buildTextField("Área", aretalhaoController, "Área",
                    readOnly: true),
                const SizedBox(height: 8),
                _buildTextField("Área Trabalhada", areaTrabalhadaController,
                    "Digite a área trabalhada (ex: 10 ha)"),
                const SizedBox(height: 16),
                const Text(
                  "Jornada de Trabalho",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimePicker(
                          "Horário Inicial", _horarioInicial, true),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimePicker(
                          "Horário Final", _horarioFinal, false),
                    ),
                  ],
                ),
                if (_horarioError)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '⚠️ Jornada Final deve ser maior que o Inicial!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                ButtonComponents(
                  onPressed: _salvarRegistro,
                  text: 'Salvar e Avançar',
                  textColor: AppColorsComponents.hashours,
                  backgroundColor: AppColorsComponents.primary,
                  fontSize: 18,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 37,
                    vertical: 12,
                  ),
                  textAlign: Alignment.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool readOnly = false,
    List list = const [],
    bool isNumeric = false,
    Function(dynamic value)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
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
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTimePicker(String label, String? time, bool isInicial) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        ElevatedButton(
          onPressed: () => _selecionarHorario(context, isInicial),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            time ?? "Selecione",
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
