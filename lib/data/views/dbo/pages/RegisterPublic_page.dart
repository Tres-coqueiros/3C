import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:senior/data/core/interface/app_interface.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/global_data.dart';
import 'package:senior/data/views/dbo/pages/RegisterActivity_page.dart';
import 'package:senior/data/views/horaextras/pages/loading_page.dart';
import 'package:senior/data/views/widgets/base_layout.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/app_text_components.dart';
import 'package:senior/data/views/widgets/components/button_components.dart';
import 'package:senior/data/views/widgets/components/search_components.dart';

class RegisterPublicDBO extends StatefulWidget {
  @override
  _RegisterPublicDBOState createState() => _RegisterPublicDBOState();
}

class _RegisterPublicDBOState extends State<RegisterPublicDBO> {
  final GetServices getServices = GetServices();
  final PostServices postServices = PostServices();
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
  int? operadorSelecionado;
  int? safraSelecionada;
  int? talhaoSelecionado;
  int? culturaSelecionada;
  int? fazendaSelecionada;
  int? cicloSelecionada;
  bool _horarioError = false;
  bool _horimetroError = false;
  bool areamaior = false;
  List<Map<String, dynamic>> getOperacao = [];
  List<Operador> getOperador = [];

  bool isLoading = false;

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
      final sid = op['safraId'];
      if (sid != null && !seen.contains(sid)) {
        seen.add(sid);
        safraList.add({
          'safraId': op['safraId'],
          'Safra': op['Safra'],
          'FazendaId': op['FazendaId'],
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
              'culturaId': op['culturaId'],
              'FazendaId': op['FazendaId'],
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

  void _salvarRegistro() async {
    double areaTalhao = double.tryParse(aretalhaoController.text) ?? 0.0;
    double areaTrabalhada =
        double.tryParse(areaTrabalhadaController.text) ?? 0.0;

    final data = {
      "cadOperador": operadorSelecionado,
      "safra": safraSelecionada,
      "talhao": talhaoSelecionado,
      "fazenda": fazendaSelecionada,
      "cultura": culturaSelecionada,
      "ciclo": cicloSelecionada,
      "areaTalhao": areaTalhao,
      "areaTrabalhada": areaTrabalhada,
    };

    setState(() {
      _horarioError = _horarioInicial == null || _horarioFinal == null;
      areamaior = areaTrabalhada > areaTalhao;
    });

    if (_formKey.currentState!.validate() && areaTrabalhada > areaTalhao) {
      areamaior = true;
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return LoadingPage(message: "Carregando...");
      },
    );

    final response = await postServices.postBDO(data);
    await Future.delayed(const Duration(seconds: 2));

    if (response['success']) {
      final generatedId = response['id'];

      final registro = {
        'generatedId': generatedId,
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
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao salvar dados!"),
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
                SearchableDropdown(
                  items: getOperador,
                  itemLabel: (operador) => operador.Nome,
                  onItemSelected: (operador) {
                    setState(() {
                      operadorSelecionado = operador.Codigo;
                    });
                    operadorSelecionado = operador.Codigo;
                  },
                  labelText: "Operador",
                  hintText: "Selecione o operador",
                ),
                const SizedBox(height: 8),
                SearchableDropdown(
                  items: getUniqueSafras(),
                  itemLabel: (safra) => safra['Safra'],
                  onItemSelected: (safra) {
                    setState(() {
                      safraSelecionada = safra['safraId'];
                      print(safra['FazendaId']);
                      fazendaSelecionada = safra['FazendaId'];
                      fazendaController.text = safra['Fazenda'] ?? '';

                      print(fazendaSelecionada);
                    });
                  },
                  labelText: "Safra",
                  hintText: "Selecione a safra",
                ),
                const SizedBox(height: 8),
                SearchableDropdown(
                  items: getCiclosBySafra(safraSelecionada ?? 0),
                  itemLabel: (ciclo) => ciclo['Cicloprod'] ?? '',
                  onItemSelected: (ciclo) {
                    setState(() {
                      print('safraSelecionada $safraSelecionada');
                      print(ciclo['culturaId']);
                      cicloSelecionada = ciclo['cicloId'];
                      culturaSelecionada = ciclo['culturaId'];
                      cicloController.text = ciclo['Cicloprod'] ?? '';
                      culturaController.text = ciclo['cultura'] ?? '';
                    });
                  },
                  labelText: "Ciclo",
                  hintText: "Selecione o ciclo",
                ),
                AppTextComponents(
                  label: "Cultura",
                  controller: culturaController,
                  hint: "Cultura",
                  readOnly: true,
                ),
                AppTextComponents(
                  label: "Fazenda",
                  controller: fazendaController,
                  hint: "Fazenda",
                  readOnly: true,
                ),
                SearchableDropdown(
                  items: getTalhaoBySafra(safraSelecionada ?? 0),
                  itemLabel: (talhao) => talhao['Talhao'] ?? '',
                  onItemSelected: (talhao) {
                    setState(() {
                      talhaoSelecionado = talhao['talhaoId'];
                      talhaoController.text = talhao['Talhao'];
                      aretalhaoController.text =
                          talhao['area'].toString() ?? '';
                    });
                  },
                  labelText: "Talhão",
                  hintText: "Selecione o talhão",
                ),
                AppTextComponents(
                  label: "Área",
                  controller: aretalhaoController,
                  hint: "Área",
                  readOnly: true,
                ),
                AppTextComponents(
                  label: "Área Trabalhada",
                  controller: areaTrabalhadaController,
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

  Widget _buildTimePicker(String label, String? time, bool isInicial) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        ElevatedButton(
          onPressed: () => _selecionarHorario(context, isInicial),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[50],
            foregroundColor: Colors.grey[800],
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                time ?? "Selecionar horário",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
