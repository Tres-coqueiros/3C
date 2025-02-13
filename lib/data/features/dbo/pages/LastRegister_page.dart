import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior/data/app_database.dart';
//import 'package:senior/data/database/app_database.dart';

class LastRegisterPage extends StatelessWidget {
  final int registroId; // Agora recebemos o ID da atividade

  const LastRegisterPage({super.key, required this.registroId});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context, listen: false);

    return FutureBuilder<Atividade?>(
      future:
          database.obterAtividadePorId(registroId), // Busca no banco pelo ID
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detalhes do Registro'),
              backgroundColor: Colors.green[800],
            ),
            body: const Center(
              child: Text(
                'Nenhum registro encontrado.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.green[800],
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back),
            ),
          );
        }

        final atividade = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detalhes do Registro'),
            backgroundColor: Colors.green[800],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildDetailRow("Descrição", atividade.descricao),
                _buildDetailRow("Coordenador", atividade.coordenador),
                _buildDetailRow("Patrimônio", atividade.patrimonio),
                _buildDetailRow("Horário Inicial", atividade.horarioInicial),
                _buildDetailRow("Horário Final", atividade.horarioFinal),
                _buildDetailRow(
                    "Horímetro Inicial", atividade.horimetroInicial),
                _buildDetailRow("Horímetro Final", atividade.horimetroFinal),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.green[800],
            onPressed: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back),
          ),
        );
      },
    );
  }

  /// **Cria um widget de linha de detalhe**
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : 'Não informado',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
