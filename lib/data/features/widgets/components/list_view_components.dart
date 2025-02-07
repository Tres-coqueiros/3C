import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:senior/data/core/network/api_services.dart';
import 'package:senior/data/core/network/exceptions_network.dart';
import 'package:senior/data/features/widgets/components/app_colors_components.dart';
import 'package:senior/data/features/widgets/components/button_components.dart';
import 'package:senior/data/features/widgets/messages/dialog_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListViewComponents extends StatefulWidget {
  final Map<String, dynamic> colaborador;

  ListViewComponents({super.key, required this.colaborador});

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

  double totalHorasExtras = 0.0;
  double totalHours = 0.0;

  @override
  void initState() {
    super.initState();
    loadApprovedHours().then((hours) {
      setState(() {
        approvedHours = hours;
      });
    });
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await getServices.getCollaborators();
      setState(() {
        totalHorasExtras = 0.0;
        horasExtrasAcumuladas.clear();
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
        selectedHours = List.from(horasExtrasAcumuladas);
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
  }

  void acceptHours(BuildContext context, String motivo) async {
    final data = {
      'numcad': widget.colaborador['NUMCAD'],
      'tipcol': widget.colaborador['TIPCOL'],
      'numemp': widget.colaborador['NUMEMP'],
      'motivo': motivo,
      'selectedHours': selectedHours
    };

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao enviar dados!"),
          backgroundColor: AppColorsComponents.error,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      bool success = await postServices.postHours(data);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Horas extras aprovadas com sucesso!"),
            backgroundColor: AppColorsComponents.success,
          ),
        );

        setState(() {
          approvedHours.addAll(selectedHours.map((hour) => hour));
          selectedHours
              .removeWhere((hour) => approvedHours.contains(hour.trim()));
        });

        await saveApprovedHours(approvedHours);

        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao aprovar"),
            backgroundColor: AppColorsComponents.error,
          ),
        );
      }
    } catch (error) {
      ErrorNotifier.showError("Erro ao aprovar horas extras: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void disapproveHours(BuildContext context, String motivo) async {
    final String status = 'aprovada';
    final data = {
      'numcad': widget.colaborador['NUMCAD'],
      'nomfun': widget.colaborador['NOMFUN'],
      'tipcol': widget.colaborador['TIPCOL'],
      'numemp': widget.colaborador['NUMEMP'],
      'titred': widget.colaborador['TITRED'],
      'nomloc': widget.colaborador['NOMLOC'],
      'motivo': motivo,
      'selectedHours': selectedHours,
      'status': status
    };

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao enviar dados!"),
          backgroundColor: AppColorsComponents.error,
        ),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      bool success = await postServices.postSendEmail(data);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Horas extras reprovadas com sucesso!"),
            backgroundColor: AppColorsComponents.success,
          ),
        );

        setState(() {
          approvedHours.addAll(selectedHours.map((hour) => hour));
          selectedHours
              .removeWhere((hour) => approvedHours.contains(hour.trim()));
        });

        await saveApprovedHours(approvedHours);

        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao reprovar"),
            backgroundColor: AppColorsComponents.error,
          ),
        );
      }
    } catch (error) {
      print("Erro ao reprovar horas extras: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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

          totalHorasExtras += (horas * 60) + minutos;

          String registro =
              "${DateFormat("dd/MM/yyyy").format(parsedDate)} - $horasString h";

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

  Future<List<String>> getSavedSelectedHours() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('selectedHours') ?? [];
  }

  Future<void> saveApprovedHours(List<String> approvedHours) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('approvedHours', approvedHours);
  }

  Future<List<String>> loadApprovedHours() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('approvedHours') ?? [];
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
                            'Total de Horas Extras: ${totalHours.toInt()}',
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
