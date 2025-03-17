// lib/data/views/logs/logs_page.dart
import 'package:flutter/material.dart';
import 'package:senior/data/core/interface/app_interface.dart';

class LogsPage extends StatelessWidget {
  final List<LogEntry> logs; // se você usa LogEntry

  const LogsPage({Key? key, required this.logs}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Atividades'),
      ),
      body: logs.isEmpty
          ? const Center(
              child: Text(
                'Nenhum registro de atividade encontrado.',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return _buildLogItem(log);
              },
            ),
    );
  }

  Widget _buildLogItem(LogEntry log) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.receipt_long),
        title: Text(
          '${log.atividade} - ${log.usuario}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data/Hora: ${_formatDateTime(log.dataHora)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(log.descricao),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final dia = dt.day.toString().padLeft(2, '0');
    final mes = dt.month.toString().padLeft(2, '0');
    final ano = dt.year;
    final hora = dt.hour.toString().padLeft(2, '0');
    final minuto = dt.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano $hora:$minuto';
  }
}
