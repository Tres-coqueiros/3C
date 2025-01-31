import 'package:flutter/material.dart';

class TelaDetalhesRegistro extends StatelessWidget {
  final Map<String, dynamic> registro;

  const TelaDetalhesRegistro({
    super.key,
    required this.registro,
  });

  @override
  Widget build(BuildContext context) {
    if (registro.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes do Registro'),
        ),
        body: const Center(
          child: Text('Nenhum registro selecionado.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Registro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Matrícula:', registro['matricula']),
            _buildDetailRow(
                'Patrimônio Implemento:', registro['patrimonioImplemento']),
            _buildDetailRow('Horário Inicial:',
                registro['horarioInicial'] ?? 'Não informado'),
            _buildDetailRow(
                'Horário Final:', registro['horarioFinal'] ?? 'Não informado'),
            _buildDetailRow('Patrimônio:', registro['patrimonio']),
            _buildDetailRow(
                'Nome do Coordenador:', registro['nomeCoordenador']),
            _buildDetailRow(
                'Operação:', registro['operacao'] ?? 'Não informado'),
            _buildDetailRow('Motivo:', registro['motivo'] ?? 'Não informado'),
            _buildDetailRow('Talhão:', registro['talhao'] ?? 'Não informado'),
            _buildDetailRow('Cultura:', registro['cultura'] ?? 'Não informado'),
            _buildDetailRow('Horímetro Inicial:',
                registro['horimetroInicial']?.toString() ?? 'Não informado'),
            _buildDetailRow('Horímetro Final:',
                registro['horimetroFinal']?.toString() ?? 'Não informado'),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
