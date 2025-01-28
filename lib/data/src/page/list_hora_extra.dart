import 'package:flutter/material.dart';
import 'package:senior/data/src/components/button_accept.dart';
import 'package:senior/data/src/components/list_colaboradores.dart';
import 'package:senior/data/src/layout/base_layout.dart';
import 'package:senior/data/utils/dialog_message.dart';

class ListHoraExtra extends StatefulWidget {
  final Colaborador colaborador;

  const ListHoraExtra({Key? key, required this.colaborador}) : super(key: key);

  @override
  _ListHoraExtra createState() => _ListHoraExtra();
}

class _ListHoraExtra extends State<ListHoraExtra> {
  void showMotivo(BuildContext context) async {
    String motivo = await DialogUtils.showConfirmationDialog(
          context: context,
          title: 'Confirmação',
          content: 'Tem certeza que deseja deletar a categoria?',
        ) ??
        '';

    if (motivo.isNotEmpty) {
      AcceptHors(context, motivo);
    }
  }

  void AcceptHors(BuildContext context, String Motivo) {
    try {
      print("Horas extras aprovadas para");
    } catch (error) {
      print("Erro ao aprovar horas extras: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
        body: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 6.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informações do Colaborador
                _buildInfoRow(Icons.person, 'Nome', widget.colaborador.nome),
                Divider(color: Colors.grey[300], thickness: 1),
                _buildInfoRow(Icons.access_time, 'Horas Extras',
                    widget.colaborador.horasExtras.toString()),
                Divider(color: Colors.grey[300], thickness: 1),
                _buildInfoRow(Icons.work, 'Jornada',
                    widget.colaborador.Jornada.toString()),
                Divider(color: Colors.grey[300], thickness: 1),
                _buildInfoRow(
                    Icons.work_outline, 'Cargo', widget.colaborador.Cargo),
                SizedBox(height: 24),
                Center(
                  child: ButtonAccept(
                    onPressed: () => showMotivo(context),
                    text: 'Aprovar Hora Extra',
                  ),
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
