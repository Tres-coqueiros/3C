import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/core/repository/exceptions_network.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/button_components.dart';
import 'package:senior/data/views/widgets/messages/dialog_message.dart';

class ListViewComponents extends StatefulWidget {
  final Map<String, dynamic> colaborador;

  ListViewComponents(
      {super.key,
      required this.colaborador,
      required Null Function(dynamic horasSelecionadas) onHorasSelecionadas});

  @override
  _ListViewComponentsState createState() => _ListViewComponentsState();
}

class _ListViewComponentsState extends State<ListViewComponents> {
  final PostServices postServices = PostServices();
  final GetServices getServices = GetServices();
  bool isAprovar = true;
  bool isLoading = false;
  bool selectAll = false;

  List<String> selectedHours = [];
  List<String> horasExtrasAcumuladas = [];
  List<String> approvedHours = [];
  List<Map<String, dynamic>> getGestor = [];

  double totalHorasExtras = 0.0;
  double totalHours = 0.0;

  int numFun = 0;
  int numemp = 0;
  int tipcol = 0;

  @override
  void initState() {
    super.initState();
    fetchGestor();
    fetchData();
  }

  void fetchGestor() async {
    try {
      final result = await getServices.getLogin();

      if (result.isNotEmpty) {
        numFun = result[0]['numcad'];
        numemp = result[0]['numemp'];
        tipcol = result[0]['tipcol'];
      }

      setState(() {
        getGestor = result;
      });
    } catch (error) {
      print('Erro ao buscar gestor: $error');
      ErrorNotifier.showError("Erro ao buscar gestor: $error");
    }
  }

  Future<void> submitHours(
      BuildContext context, String motivo, String status) async {
    if (selectedHours.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Nenhuma hora selecionada!"),
          backgroundColor: AppColorsComponents.error,
        ),
      );
      return;
    }

    final Map<String, dynamic> data = {
      'numcad': widget.colaborador['NUMCAD'],
      'nomfun': widget.colaborador['NOMFUN'],
      'tipcol': widget.colaborador['TIPCOL'],
      'numemp': widget.colaborador['NUMEMP'],
      'titred': widget.colaborador['TITRED'],
      'nomloc': widget.colaborador['NOMLOC'],
      'numFunAut': numFun,
      'numempAut': numemp,
      'tipcolAut': tipcol,
      'motivo': motivo,
      'selectedHours': selectedHours,
      'status': status,
    };

    setState(() => isLoading = true);

    try {
      bool success = await postServices.postHours(data);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? "Horas extras $status com sucesso!"
              : "Erro ao ${status == 'aprovada' ? 'aprovar' : 'reprovar'} horas"),
          backgroundColor:
              success ? AppColorsComponents.success : AppColorsComponents.error,
        ),
      );

      if (success) {
        if (status == 'reprovada') {
          setState(() {
            approvedHours.addAll(selectedHours);
          });
        }
        await fetchData();
      }
    } catch (error) {
      ErrorNotifier.showError("Erro ao $status horas extras: $error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await getServices.getCollaborators();

      final colaboradorAtualizado = data.firstWhere(
        (colab) => colab['NUMCAD'] == widget.colaborador['NUMCAD'],
        orElse: () => widget.colaborador,
      );

      setState(() {
        totalHorasExtras = 0.0;
        horasExtrasAcumuladas.clear();
        widget.colaborador['ListHorasExtras'] =
            colaboradorAtualizado['ListHorasExtras'];
        getHours(widget.colaborador);
      });
    } catch (error) {
      print('Erro ao carregar os dados: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao carregar dados."),
          backgroundColor: AppColorsComponents.error,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleSelectAll() {
    setState(() {
      if (selectAll) {
        selectedHours.clear();
      } else {
        selectedHours = horasExtrasAcumuladas
            .where((hora) => !approvedHours.contains(hora))
            .toList();
      }
      selectAll = !selectAll;
    });
  }

  void showMotivo(BuildContext context) async {
    if (selectedHours.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Selecione pelo menos uma hora extra!"),
          backgroundColor: AppColorsComponents.error,
        ),
      );
      return;
    }

    String? motivo = await DialogUtils.showConfirmationDialog(
      context: context,
      title: 'Confirmação',
      content: isAprovar
          ? 'Tem certeza que deseja aprovar as horas extras selecionadas?'
          : 'Tem certeza que deseja reprovar as horas extras selecionadas?',
    );

    if (motivo != null && motivo.isNotEmpty) {
      isAprovar
          ? acceptHours(context, motivo)
          : disapproveHours(context, motivo);
    }
    await fetchData();
  }

  void acceptHours(BuildContext context, String motivo) async {
    await submitHours(context, motivo, 'aprovado');
  }

  void disapproveHours(BuildContext context, String motivo) async {
    await submitHours(context, motivo, 'reprovado');
  }

  List<String> getHours(Map<String, dynamic> colaborador) {
    if (colaborador['ListHorasExtras'] == null ||
        colaborador['ListHorasExtras'].isEmpty) {
      print('Nenhuma hora extra encontrada.');
      return horasExtrasAcumuladas;
    }

    totalHorasExtras = 0.0;
    List<String> horasNoBanco = colaborador['HorasBanco'] ?? [];

    colaborador['ListHorasExtras'].forEach((horaExtra) {
      String? horaExtraDate = horaExtra['DATA_EXTRA']?.toString();
      if (horaExtraDate != null) {
        try {
          DateTime parsedDate = DateTime.parse(horaExtraDate).toUtc();
          String horasString = horaExtra['HORA_EXTRA']?.toString() ?? "00:00";

          List<String> partes = horasString.split(':');
          if (partes.length != 2) {
            print("Erro: Formato inválido");
            return;
          }

          int horas = int.tryParse(partes[0]) ?? 0;
          int minutos = int.tryParse(partes[1]) ?? 0;

          // Converte minutos para horas e soma ao total
          totalHorasExtras += horas + (minutos / 60);

          String registro =
              "${DateFormat("dd/MM/yyyy").format(parsedDate)} - $horasString";

          if (!horasExtrasAcumuladas.contains(registro)) {
            horasExtrasAcumuladas.add(registro);
          }

          if (horasNoBanco.contains(registro)) {
            if (!approvedHours.contains(registro)) {
              approvedHours.add(registro);
            }
          }
        } catch (error) {
          ErrorNotifier.showError(
              'Erro ao converter a data da hora extra: $error');
        }
      }
    });

    setState(() {
      totalHours = totalHorasExtras;
    });

    return horasExtrasAcumuladas;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    final horasExtras = getHours(widget.colaborador);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 3.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 4.0),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.grey[600],
                            size: 16.0,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            'Total de Horas Extras: ${totalHours.toStringAsFixed(2)} h',
                            style: TextStyle(
                                fontSize: 14.0, color: Colors.grey[600]),
                          ),
                          Spacer(),
                          Checkbox(
                            value: selectAll,
                            onChanged: (bool? value) {
                              setState(() {
                                toggleSelectAll();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Horas Extras Registradas:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColorsComponents.secondary),
                  ),
                  SizedBox(height: 8.0),
                  horasExtras.isNotEmpty
                      ? Container(
                          height: 150.0, // Altura fixa para a lista
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount: horasExtras.length,
                            itemBuilder: (context, index) {
                              final horaExtra = horasExtras[index];
                              final isApproved =
                                  approvedHours.contains(horaExtra);

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    horaExtra,
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey[700]),
                                  ),
                                  Checkbox(
                                    value: selectedHours.contains(horaExtra),
                                    onChanged: approvedHours.contains(horaExtra)
                                        ? null
                                        : (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedHours.add(horaExtra);
                                              } else {
                                                selectedHours.remove(horaExtra);
                                              }
                                            });
                                          },
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      : Text(
                          "Nenhuma hora extra registrada.",
                          style: TextStyle(
                              fontSize: 14.0, color: Colors.grey[700]),
                        ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ButtonComponents(
                        onPressed: () {
                          setState(() => isAprovar = true);
                          showMotivo(context);
                        },
                        textAlign: Alignment.centerRight,
                        text: 'Aprovar',
                        backgroundColor: AppColorsComponents.primary,
                        textColor: Colors.white,
                        fontSize: 14,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      ButtonComponents(
                        onPressed: () {
                          setState(() => isAprovar = false);
                          showMotivo(context);
                        },
                        textAlign: Alignment.centerLeft,
                        text: 'Reprovar',
                        backgroundColor: AppColorsComponents.error,
                        textColor: Colors.white,
                        fontSize: 14,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
