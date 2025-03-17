import 'package:flutter/material.dart';
import 'package:senior/data/core/repository/api_repository.dart';

class Logspage extends StatefulWidget {
  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<Logspage> {
  final GetServices getServices = GetServices();
  List<LogEntry> getLogs = [];

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  void fetchLogs() async {
    try {
      final result = await getServices.getLogs();
      setState(() {
        getLogs = result.map((logs) {
          return LogEntry(
            usuario: logs['usuario_id'].toString(),
            atividade: logs['tipo'].toString(),
            descricao: logs['mensagem'].toString(),
            dataHora: DateTime.parse(logs['data'].toString()),
          );
        }).toList();
      });
    } catch (error) {
      print('Erro ao carregar atividades: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Atividades'),
      ),
      body: getLogs.isEmpty
          ? const Center(
              child: Text(
                'Nenhum registro de atividade encontrado.',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: getLogs.length,
              itemBuilder: (context, index) {
                final log = getLogs[index];
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

class LogEntry {
  final String usuario;
  final String atividade;
  final String descricao;
  final DateTime dataHora;

  LogEntry({
    required this.usuario,
    required this.atividade,
    required this.descricao,
    required this.dataHora,
  });
}
