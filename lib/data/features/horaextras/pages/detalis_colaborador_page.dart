import 'package:flutter/material.dart';
import 'package:senior/data/core/widgets/buttons/button_accept.dart';
import 'package:senior/data/features/widgets/base_layout.dart';
// import 'package:senior/data/core/widgets/buttons/button_disapprove.dart';
// import 'package:senior/data/features/widgets/base_layout.dart';
import 'package:senior/data/features/widgets/buttons/button_accept.dart';
import 'package:senior/data/features/widgets/buttons/button_disapprove.dart';
import 'package:senior/data/features/widgets/messages/dialog_message.dart';

class ListHoraExtra extends StatefulWidget {
  @override
  _ListHoraExtra createState() => _ListHoraExtra();
}

class _ListHoraExtra extends State<ListHoraExtra> {
  // Função para mostrar o motivo de aprovação
  void showMotivo(BuildContext context) async {
    String? motivo = await DialogUtils.showConfirmationDialog(
      context: context,
      title: 'Confirmação',
      content: 'Tem certeza que deseja aprovar essa hora?',
    );

    if (motivo != null && motivo.isNotEmpty) {
      AcceptHors(context, motivo); // Aprovar a hora
    }
  }

  // Função para mostrar o motivo de reprovação
  void showMotivoRe(BuildContext context) async {
    String? motivo = await DialogUtils.showConfirmationDialog(
      context: context,
      title: 'Confirmação',
      content: 'Tem certeza que deseja reprovar essa hora?',
    );

    if (motivo != null && motivo.isNotEmpty) {
      DisapproveHors(context, motivo); // Reprovar a hora
    }
  }

  // Função de aprovação de horas extras
  void AcceptHors(BuildContext context, String motivo) {
    try {
      // Aqui você pode adicionar a lógica para aprovar a hora, como uma requisição à API
      print('Horas extras aprovadas. Motivo: $motivo');
      // Exemplo de como você pode fazer uma requisição para a API para aprovar as horas.
    } catch (error) {
      print("Erro ao aprovar horas extras: $error");
    }
  }

  // Função de reprovação de horas extras
  void DisapproveHors(BuildContext context, String motivo) {
    try {
      // Aqui você pode adicionar a lógica para reprovar a hora, como uma requisição à API
      print('Horas extras reprovadas. Motivo: $motivo');
      // Exemplo de como você pode fazer uma requisição para a API para reprovar as horas.
    } catch (error) {
      print("Erro ao reprovar horas extras: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // Informações do Colaborador
                  // _buildInfoRow(Icons.person, 'Nome', widget.colaborador.nome),
                  // Divider(color: Colors.grey[300], thickness: 1),
                  // _buildInfoRow(Icons.access_time, 'Horas Extras',
                  //     widget.colaborador.horasExtras.toString()),
                  // Divider(color: Colors.grey[300], thickness: 1),
                  // _buildInfoRow(Icons.work, 'Jornada',
                  //     widget.colaborador.nome.toString()),
                  // Divider(color: Colors.grey[300], thickness: 1),
                  // _buildInfoRow(
                  //     Icons.work_outline, 'Cargo', widget.colaborador.jornada),
                  SizedBox(height: 24),
                  // Botões Aprovar e Reprovar lado a lado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botão Aprovar
                      Expanded(
                        child: ButtonAccept(
                          onPressed: () => showMotivo(context),
                          text: 'Aprovar',
                        ),
                      ),
                      SizedBox(width: 16), // Espaço entre os botões
                      // Botão Reprovar
                      Expanded(
                        child: ButtonDisapprove(
                          onPressed: () => showMotivoRe(context),
                          text: 'Reprovar',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Função para criar as linhas de informações
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
