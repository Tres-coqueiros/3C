import 'package:flutter/material.dart';

class LastRegisterPage extends StatelessWidget {
  final Map<String, dynamic> registro;

  const LastRegisterPage({super.key, required this.registro});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Registro'),
        backgroundColor: Colors.green[800],
      ),
      body: registro.isEmpty
          ? const Center(
              child: Text(
                'Nenhum registro selecionado.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: registro.entries
                    .map((entry) => Column(
                          children: [
                            _buildDetailRow(entry.key, entry.value),
                            const Divider(),
                          ],
                        ))
                    .toList(),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[800],
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
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
              value != null ? value.toString() : 'Não informado',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
