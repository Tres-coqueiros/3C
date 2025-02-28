import 'dart:ffi';

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
  bool areamaior = false;
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

  List<Map<String, dynamic>> getCiclosBySafra(int safraId) {
    final seen = <int>{};
    return getOperacao
        .where((op) => op['safraId'] == safraId)
        .where((op) => seen.add(op['cicloId']))
        .map((op) => {
              'cicloId': op['cicloId'],
              'Cicloprod': op['Cicloprod'],
              'cultura': op['cultura'],
              'area': op['area'],
            })
        .toList();
  }

  List<Map<String, dynamic>> getTalhaoBySafra(int safraId) {
    final seen = <int>{};
    return getOperacao
        .where((op) => op['safraId'] == safraId)
        .where((op) => seen.add(op['talhaoId']))
        .map((op) => {
              'talhaoId': op['talhaoId'],
              'Talhao': op['Talhao'],
              'area': op['area'],
            })
        .toList();
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
    double areaTalhao = double.tryParse(aretalhaoController.text) ?? 0.0;
    double areaTrabalhada =
        double.tryParse(areaTrabalhadaController.text) ?? 0.0;

    setState(() {
      _horarioError = _horarioInicial == null || _horarioFinal == null;
      areamaior = areaTrabalhada > areaTalhao;
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

      if (_formKey.currentState!.validate() && areaTalhao > areaTalhao) {
        areamaior = true;
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BaseLayout(
            body: RegisterActivityPage(
              dados: listaDeRegistros,
              informacoesGerais: registro,
              atividade: registro,
            ),
          ),
        ),
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
                // Operador
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

                // Safra
                SearchableDropdown(
                  items: getUniqueSafras(),
                  itemLabel: (safra) => safra['Safra'],
                  onItemSelected: (safra) {
                    setState(() {
                      safraSelecionada = safra['safraId'];
                      fazendaController.text =
                          safra['Fazenda']?.toString() ?? '';
                    });
                  },
                  labelText: "Safra",
                  hintText: "Selecione a safra",
                ),
                const SizedBox(height: 8),

                // Ciclo
                SearchableDropdown(
                  items: getCiclosBySafra(safraSelecionada ?? 0),
                  itemLabel: (ciclo) => ciclo['Cicloprod'] ?? '',
                  onItemSelected: (ciclo) {
                    setState(() {
                      cicloSelecionada = ciclo['cicloId']?.toString() ?? '';
                      cicloController.text = ciclo['Cicloprod'] ?? '';
                      culturaController.text = ciclo['cultura'] ?? '';
                    });
                  },
                  labelText: "Ciclo",
                  hintText: "Selecione o ciclo",
                ),
                const SizedBox(height: 8),

                // Cultura
                _buildTextField(
                  "Cultura",
                  cultureController: culturaController,
                  hint: "Cultura",
                  readOnly: true,
                ),

                // Fazenda
                _buildTextField(
                  "Fazenda",
                  cultureController: fazendaController,
                  hint: "Fazenda",
                  readOnly: true,
                ),
                const SizedBox(height: 8),

                // Talhão
                SearchableDropdown(
                  items: getTalhaoBySafra(safraSelecionada ?? 0),
                  itemLabel: (talhao) => talhao['Talhao'] ?? '',
                  onItemSelected: (talhao) {
                    setState(() {
                      talhaoSelecionado = talhao['talhaoId'];
                      talhaoController.text =
                          talhao['Talhao']?.toString() ?? '';
                      aretalhaoController.text =
                          talhao['area']?.toString() ?? '';
                    });
                  },
                  labelText: "Talhão",
                  hintText: "Selecione o talhão",
                ),
                const SizedBox(height: 8),

                // Área do Talhão
                _buildTextField(
                  "Área",
                  cultureController: aretalhaoController,
                  hint: "Área",
                  readOnly: true,
                ),
                const SizedBox(height: 8),

                // Área Trabalhada
                _buildTextField(
                  "Área Trabalhada",
                  cultureController: areaTrabalhadaController,
                  hint: "Digite a área trabalhada (ex: 10 ha)",
                ),
                if (areamaior)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Àrea Trabalhada é maior que a Àrea do Talhão!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                const Text(
                  "Jornada de Trabalho",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Horários
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

                // Botão
                ButtonComponents(
                  onPressed: _salvarRegistro,
                  text: 'Salvar e Avançar',
                  textColor: AppColorsComponents.hashours,
                  backgroundColor: AppColorsComponents.primary,
                  fontSize: 18,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 37, vertical: 12),
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
    String label, {
    required TextEditingController cultureController,
    required String hint,
    bool readOnly = false,
    bool isNumeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: cultureController,
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
