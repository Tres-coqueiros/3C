import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:senior/data/core/network/api_services.dart';
import 'package:senior/data/features/widgets/components/app_colors_components.dart';
import 'package:senior/data/features/widgets/components/button_components.dart';
import 'package:senior/data/features/widgets/messages/dialog_message.dart';

class ListViewComponents extends StatefulWidget {
  final Map<String, dynamic> colaborador;

  ListViewComponents({super.key, required this.colaborador});

  @override
  _ListViewComponentsState createState() => _ListViewComponentsState();
}

class _ListViewComponentsState extends State<ListViewComponents> {
  final PostServices postServices = PostServices();
  bool isAprovar = true;
  bool isLoading = false;
  List<String> selectedHours = [];
  bool selectAll = false;

  double totalHorasExtras = 0.0;
  double totalHours = 0.0;

  void toggleSelectAll() {
    setState(() {
      if (selectAll) {
        selectedHours.clear();
      } else {
        selectedHours = getHours(widget.colaborador);
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
        for (var hour in selectedHours) {
          selectedHours.remove(hour);
        }
        ;
      }
    } catch (error) {
      print("Erro ao aprovar horas extras: $error");
    }
    setState(() {
      isLoading = false;
    });
  }

  void disapproveHours(BuildContext context, String motivo) async {
    final data = {
      'numcad': widget.colaborador['NUMCAD'],
      'nomfun': widget.colaborador['NOMFUN'],
      'tipcol': widget.colaborador['TIPCOL'],
      'numemp': widget.colaborador['NUMEMP'],
      'titred': widget.colaborador['TITRED'],
      'nomloc': widget.colaborador['NOMLOC'],
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
    try {
      bool success = await postServices.postSendEmail(data);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Horas extras reprovadas com sucesso!"),
            backgroundColor: AppColorsComponents.success,
          ),
        );
      }
    } catch (error) {
      print("Erro ao reprovar horas extras: $error");
    }
  }

  List<String> getHours(Map<String, dynamic> colaborador) {
    DateTime dataOntem = DateTime.now().subtract(Duration(days: 1));
    DateTime dataOntemInicio =
        DateTime(dataOntem.year, dataOntem.month, dataOntem.day, 0, 0, 0)
            .toUtc();
    DateTime dataOntemFim =
        DateTime(dataOntem.year, dataOntem.month, dataOntem.day, 23, 59, 59)
            .toUtc();

    print('dataOntemInicio $dataOntemInicio');
    print('dataOntemFim $dataOntemFim');

    if (colaborador['ListHorasExtras'] == null ||
        colaborador['ListHorasExtras'].isEmpty) {
      print('Nenhuma hora extra encontrada.');
      return [];
    }

    if (colaborador['ListJornada'] == null ||
        colaborador['ListJornada'].isEmpty) {
      print('Nenhuma jornada encontrada.');
      return [];
    }

    double totalHorasExtras = 0.0;

    final horasExtras = colaborador['ListHorasExtras'].where((horaExtra) {
      String? horaExtraDate = horaExtra['DATA_EXTRA']?.toString();
      if (horaExtraDate != null) {
        try {
          DateTime parsedDate = DateTime.parse(horaExtraDate).toUtc();
          return parsedDate.isAfter(dataOntemInicio) &&
              parsedDate.isBefore(dataOntemFim);
        } catch (e) {
          print('Erro ao converter a data da hora extra: $e');
          return false;
        }
      }
      return false;
    }).map<String>((horaExtra) {
      String? horasString = horaExtra['HORA_EXTRA']?.toString();
      if (horasString == null || horasString.isEmpty) {
        return "Erro: Dados inválidos";
      }

      List<String> partes = horasString.split(':');
      if (partes.length != 2) {
        return "Erro: Formato inválido";
      }

      int horas = int.tryParse(partes[0]) ?? 0;
      int minutos = int.tryParse(partes[1]) ?? 0;

      totalHorasExtras += (horas * 60) + minutos;

      return "${DateFormat("dd/MM/yyyy").format(DateTime.parse(horaExtra['DATA_EXTRA']))} - ${horaExtra['HORA_EXTRA']} h";
    }).toList();

    setState(() {
      totalHours = totalHorasExtras;
    });

    return horasExtras;
  }

  @override
  Widget build(BuildContext context) {
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
                                    onChanged: (bool? value) {
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
