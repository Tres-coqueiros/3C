import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:senior/data/core/interface/app_interface.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/global_data.dart';
import 'package:senior/data/views/dbo/pages/DetailsRegister_page.dart';
import 'package:senior/data/views/horaextras/pages/loading_page.dart';
import 'package:senior/data/views/widgets/base_layout.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/app_text_components.dart';
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

class _RegisterActivityPageState extends State<RegisterActivityPage> {
  final GetServices getServices = GetServices();
  final PostServices postServices = PostServices();
  final formKey = GlobalKey<FormState>();
  final DateFormat dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  late Map<String, dynamic> informacoesGerais;

  final TextEditingController patrimonioController = TextEditingController();
  final TextEditingController patrimonioImplementoController =
      TextEditingController();
  final TextEditingController codigopatrimonioController =
      TextEditingController();
  final TextEditingController maquinaController = TextEditingController();
  final TextEditingController operacaoController = TextEditingController();
  final TextEditingController areaTrabalhadaController =
      TextEditingController();
  final TextEditingController motivoTempController = TextEditingController();
  final TextEditingController talhaoController = TextEditingController();
  final TextEditingController culturaController = TextEditingController();
  final TextEditingController horimetroInicialController =
      TextEditingController();
  final TextEditingController horimetroFinalController =
      TextEditingController();

  String? horarioInicial;
  String? horarioFinal;

  int? servicoselecionado;
  int? bemSelecionado;

  bool horaRangeError = false;
  bool horimetroError = false;
  String? horimetroErrorMessage;

  String _tempoTrabalhado = '';
  String _horimetroTotal = '';

  final List<MotivoParada> motivosParada = [];

  List<Patrimonio> getPatrimonio = [];
  List<Servicos> getServicos = [];

  @override
  void initState() {
    super.initState();
    fetchPatrimonio();
    fetchServicos();
    informacoesGerais = widget.informacoesGerais;
    horarioInicial = informacoesGerais['horarioInicial'];
    horarioFinal = informacoesGerais['horarioFinal'];
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

  void fetchServicos() async {
    try {
      final result = await getServices.getServicos();
      setState(() {
        getServicos = result.map((servicos) {
          return Servicos(
            Codigo: servicos['Codigo'],
            Servico: servicos['Servicos'],
            Tipo: servicos['Tipo'],
          );
        }).toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao buscar serviços"),
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

  Future<void> _addMotivoParada() async {
    final descricao = motivoTempController.text.trim();
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
      motivosParada.add(parada);
      motivoTempController.clear();
    });
  }

  void _selecionarHorario(BuildContext context, bool isInicial) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onConfirm: (date) {
        setState(() {
          final formatted = dateTimeFormat.format(date);
          if (isInicial) {
            horarioInicial = formatted;
          } else {
            horarioFinal = formatted;
          }
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.pt,
    );
  }

  void _handleAdicionar() async {
    final horimetroInicial =
        double.tryParse(horimetroInicialController.text) ?? 00;
    final horimetroFinal = double.tryParse(horimetroFinalController.text) ?? 00;

    setState(() {
      horaRangeError = horarioInicial != null &&
          horarioFinal != null &&
          dateTimeFormat.parse(horarioFinal!).isBefore(
                dateTimeFormat.parse(horarioInicial!),
              );

      if ((horimetroFinal - horimetroInicial) > 12) {
        horimetroError = true;
        horimetroErrorMessage = '⚠ Horímetro excede as 12 horas de trabalho!';
      }
    });

    if (!horaRangeError && !horimetroError) {
      String tempoTrabalhado = '';
      if (horarioInicial != null && horarioFinal != null) {
        final inicio = dateTimeFormat.parse(horarioInicial!);
        final fim = dateTimeFormat.parse(horarioFinal!);
        final duracao = fim.difference(inicio);
        final horas = duracao.inHours;
        final minutos = duracao.inMinutes % 60;
        tempoTrabalhado = horas > 0 ? '$horas h $minutos min' : '$minutos min';
      }

      String horimetroTotal = '';
      if (horimetroInicial != null && horimetroFinal != null) {
        final dif = horimetroFinal - horimetroInicial;
        horimetroTotal = dif.toStringAsFixed(2);
      }

      setState(() {
        _tempoTrabalhado = tempoTrabalhado;
        _horimetroTotal = horimetroTotal;
      });
    }
    final combinedData = {
      ...informacoesGerais,
      'patrimonio': patrimonioController.text,
      'patrimonioImplemento': patrimonioImplementoController.text.isNotEmpty
          ? patrimonioImplementoController.text
          : 'Não informado',
      'descricaoPatrimonio': codigopatrimonioController.text.isNotEmpty
          ? codigopatrimonioController.text
          : 'Não informado',
      'maquina': maquinaController.text,
      'operacao': operacaoController.text,
      'areaTrabalhada': areaTrabalhadaController.text,
      'motivosParada': motivosParada.map((p) {
        return {
          'descricao': p.descricao,
          'inicio': dateTimeFormat.format(p.inicio),
          'fim': dateTimeFormat.format(p.fim),
          'duracaoMin': p.duracao.inMinutes,
        };
      }).toList(),
      'talhao': talhaoController.text,
      'cultura': culturaController.text,
      'horaInicial': horarioInicial ?? 'Não informado',
      'horaFinal': horarioFinal ?? 'Não informado',
      'horimetroInicial': horimetroInicialController.text,
      'horimetroFinal': horimetroFinalController.text,
      'tempoTrabalhado': _tempoTrabalhado,
      'horimetroTotal': _horimetroTotal,
    };

    final data = {
      'producaoId': informacoesGerais['generatedId'],
      'servico': operacaoController.text.trim(),
      'bens': patrimonioController.text.trim(),
      'motivosParada': motivosParada.map((p) {
        return {
          'descricao': p.descricao,
          'inicio': p.inicio.toIso8601String(),
          'fim': p.fim.toIso8601String()
        };
      }).toList(),
      'horimetroInicial': horimetroInicialController.text,
      'horimetroFinal': horimetroFinalController.text,
      'servico_id': servicoselecionado,
      'bem_id': bemSelecionado
    };
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return LoadingPage(message: "Carregando...");
      },
    );

    try {
      final response = await postServices.postBDOperacao(data);
      await Future.delayed(const Duration(seconds: 2));

      if (response['success']) {
        print(response);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BaseLayout(
              body: DetailsregisterPage(registros: [combinedData]),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Erro desconhecido'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao salvar registro"),
        ),
      );
      print('Error: $error');
    }
    if (!listaDeRegistros.contains(combinedData)) {
      setState(() {
        listaDeRegistros.add(combinedData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Código da Operação: ${informacoesGerais['generatedId'].toString()}',
                ),
                const SizedBox(height: 8),
                SearchableDropdown(
                  items: getPatrimonio,
                  itemLabel: (patrimonio) => patrimonio.bens,
                  onItemSelected: (patrimonio) {
                    setState(() {
                      bemSelecionado = patrimonio.bensId;
                      patrimonioController.text = patrimonio.bens;
                      maquinaController.text = patrimonio.bensImple;
                      codigopatrimonioController.text =
                          patrimonio.bensId.toString();
                    });
                  },
                ),

                AppTextComponents(
                  label: "Código Patrimônio",
                  controller: codigopatrimonioController,
                  hint: "Digite a descrição do patrimônio",
                ),
                // 1) Maquina
                AppTextComponents(
                  label: "Maquina",
                  controller: maquinaController,
                  hint: "Digite o Patrimônio",
                ),

                SearchableDropdown(
                  items: getServicos,
                  itemLabel: (servicos) => servicos.Servico,
                  onItemSelected: (servicos) {
                    setState(() {
                      servicoselecionado = servicos.Codigo;
                      operacaoController.text = servicos.Servico;
                    });
                  },
                  hintText: "Digite a descrição da Operação",
                  labelText: "Operação",
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: motivoTempController,
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
                if (motivosParada.isNotEmpty)
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
                          itemCount: motivosParada.length,
                          itemBuilder: (context, index) {
                            return _buildMotivoParadaItem(motivosParada[index]);
                          },
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: AppTextComponents(
                        label: "Horímetro Inicial",
                        controller: horimetroInicialController,
                        hint: "Digite o Horímetro",
                        isNumeric: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextComponents(
                        label: "Horímetro Final",
                        controller: horimetroFinalController,
                        hint: "Digite o Horímetro (opcional)",
                        isNumeric: true,
                        isRequired: false,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

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
              'Início: ${dateTimeFormat.format(parada.inicio)}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Fim: ${dateTimeFormat.format(parada.fim)}',
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
