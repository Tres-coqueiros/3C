import 'package:flutter/material.dart';

class DetailsregisterPage extends StatefulWidget {
  final List<Map<String, dynamic>> registros;

  const DetailsregisterPage({super.key, required this.registros});

  @override
  _DetailsregisterPageState createState() => _DetailsregisterPageState();
}

class _DetailsregisterPageState extends State<DetailsregisterPage> {
  late List<Map<String, dynamic>> dados;

  @override
  void initState() {
    super.initState();
    dados = widget.registros;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Registros')),
      body: dados.isEmpty
          ? const Center(
              child: Text(
                'Nenhum registro disponível para visualização.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: dados.length,
              itemBuilder: (context, index) {
                final item = dados[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 3,
                  child: ExpansionTile(
                    title: Text(
                      'Registro ${index + 1}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfo('Matrícula', item['matricula']),
                            _buildInfo('Patrimônio Implemento',
                                item['patrimonioImplemento']),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfo('Horário Inicial',
                                    item['horarioInicial'] ?? 'Não informado'),
                                _buildInfo('Horário Final',
                                    item['horarioFinal'] ?? 'Não informado'),
                              ],
                            ),
                            _buildInfo('Patrimônio', item['patrimonio']),
                            // Adicione outros campos conforme necessário:
                            _buildInfo(
                                'Nome do Coordenador', item['nomeCoordenador']),
                            _buildInfo('Operação',
                                item['operacao'] ?? 'Não informado'),
                            _buildInfo(
                                'Motivo', item['motivo'] ?? 'Não informado'),
                            _buildInfo(
                                'Talhão', item['talhao'] ?? 'Não informado'),
                            _buildInfo(
                                'Cultura', item['cultura'] ?? 'Não informado'),
                            _buildInfo(
                                'Horímetro Inicial',
                                item['horimetroInicial']?.toString() ??
                                    'Não informado'),
                            _buildInfo(
                                'Horímetro Final',
                                item['horimetroFinal']?.toString() ??
                                    'Não informado'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

  Widget _buildInfo(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
          children: [
            TextSpan(
              text: value ?? 'Não informado',
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
