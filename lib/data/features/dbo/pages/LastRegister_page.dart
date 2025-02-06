import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

class TelaDetalhesRegistro extends StatefulWidget {
  final Map<String, dynamic> registro;

  const TelaDetalhesRegistro({
    super.key,
    required this.registro,
    // O parâmetro "registros" foi removido, pois não está sendo utilizado aqui.
  });

  @override
  Widget build(BuildContext context) {
    if (widget.registro.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes do Registro'),
        ),
        body: const Center(
          child: Text(
            'Nenhum registro selecionado.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Registro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Matrícula:', widget.registro['matricula']),
                _buildDetailRow('Patrimônio Implemento:',
                    widget.registro['patrimonioImplemento']),
                const SizedBox(height: 10),
                const Text(
                  "Horários*",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Inicial*"),
                          ElevatedButton(
                            onPressed: () => _selecionarHorario(context, true),
                            child: Text(_horarioInicial ?? "Selecione"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Final*"),
                          ElevatedButton(
                            onPressed: () => _selecionarHorario(context, false),
                            child: Text(_horarioFinal ?? "Selecione"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildDetailRow(
                    'Patrimônio:', widget.registro['patrimonio'] ?? ''),
                _buildDetailRow(
                    'Nome do Coordenador:', widget.registro['nomeCoordenador']),
                _buildDetailRow('Operação:',
                    widget.registro['operacao'] ?? 'Não informado'),
                _buildDetailRow(
                    'Motivo:', widget.registro['motivo'] ?? 'Não informado'),
                _buildDetailRow(
                    'Talhão:', widget.registro['talhao'] ?? 'Não informado'),
                _buildDetailRow(
                    'Cultura:', widget.registro['cultura'] ?? 'Não informado'),
                _buildDetailRow(
                  'Horímetro Inicial:',
                  widget.registro['horimetroInicial']?.toString() ??
                      'Não informado',
                ),
                _buildDetailRow(
                  'Horímetro Final:',
                  widget.registro['horimetroFinal']?.toString() ??
                      'Não informado',
                ),
                const SizedBox(height: 24),
                // Botão Avançar que abre o diálogo e, se confirmado, navega
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _mostrarConfirmacao,
                    child: const Text('Avançar'),
                  ),
                ),
                const SizedBox(height: 24),
                // Botão Voltar (opcional)
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Voltar"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    final String textValue = value != null ? value.toString() : 'Não informado';

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
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              textValue,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
