import 'package:flutter/material.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/views/widgets/base_layout.dart';
import 'package:senior/data/views/widgets/messages/dialog_message.dart';

class ListHoraExtra extends StatefulWidget {
  final Map<String, dynamic> colaborador;

  const ListHoraExtra({Key? key, required this.colaborador}) : super(key: key);

  @override
  _ListHoraExtra createState() => _ListHoraExtra();
}

class _ListHoraExtra extends State<ListHoraExtra> {
  final GetServices getServices = GetServices();

  bool isLoading = true;
  bool isPprovar = false;

  String nomfun = "";
  int numcad = 0;

  void showMotivo(BuildContext context) async {
    String? motivo = await DialogUtils.showConfirmationDialog(
      context: context,
      title: 'Confirmação',
      content: isPprovar
          ? 'Tem certeza que deseja aprovar essa hora?'
          : 'Tem certeza que deseja reprovar essa hora?',
    );

    if (motivo != null && motivo.isNotEmpty) {
      isPprovar ? AcceptHors(context, motivo) : DisapproveHors(context, motivo);
    }
  }

  void AcceptHors(BuildContext context, String motivo) {
    try {} catch (error) {
      print("Erro ao aprovar horas extras: $error");
    }
  }

  void DisapproveHors(BuildContext context, String motivo) {
    try {
      print('Horas extras reprovadas. Motivo: $motivo');
    } catch (error) {
      print("Erro ao reprovar horas extras: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    // String horaExtra = widget.colaborador['HORA_EXTRA'] ?? '0';
    // if (horaExtra != '0') {
    //   NotificationServices.showNotification(
    //     title: 'Horas Extras',
    //     body:
    //         'O colaborador ${widget.colaborador['NOMFUN']} tem horas extras: $horaExtra',
    //   );
    // }
    return BaseLayout(
        body: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.person, 'Matricula',
                        widget.colaborador['NUMCAD'].toString() ?? 'N/A'),
                    Divider(color: Colors.grey[300], thickness: 1),
                    _buildInfoRow(Icons.access_time, 'Horas Extras',
                        widget.colaborador['HORA_EXTRA']?.toString() ?? 'N/A'),
                    Divider(color: Colors.grey[300], thickness: 1),
                    _buildInfoRow(
                      Icons.work,
                      'Jornada',
                      widget.colaborador['ListJornada'] != null &&
                              widget.colaborador['ListJornada'].isNotEmpty
                          ? widget.colaborador['ListJornada'][0]
                                  ['HORAS_FORMATADAS'] ??
                              'N/A'
                          : 'N/A',
                    ),
                    Divider(color: Colors.grey[300], thickness: 1),
                    _buildInfoRow(Icons.work_outline, 'Cargo',
                        widget.colaborador['CARGOS'] ?? 'N/A'),
                    _buildInfoRow(
                        Icons.work_outline,
                        'Data',
                        widget.colaborador['ListJornada'] != null &&
                                widget.colaborador['ListJornada'].isNotEmpty
                            ? widget.colaborador['ListJornada'][0]['DATACC'] ??
                                'N/A'
                            : 'N/A'),
                    SizedBox(height: 24),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Expanded(
                    //   child: ButtonAccept(
                    //     onPressed: () => showMotivo(context),
                    //     text: 'Aprovar',
                    //   ),
                    // ),
                    SizedBox(width: 16),
                    // Expanded(
                    // child: ButtonDisapprove(
                    //   onPressed: () => showMotivo(context),
                    //   text: 'Reprovar',
                    // ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.green,
          size: 28.0,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
