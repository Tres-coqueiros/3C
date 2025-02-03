import 'package:flutter/material.dart';

class DetailsregisterPage extends StatefulWidget {
  _DetailsregisterPage createState() => new _DetailsregisterPage();
}

class _DetailsregisterPage extends State<DetailsregisterPage> {
  final List<Map<String, dynamic>> dados = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visualizar Registros')),
      body: dados == null || dados!.isEmpty
          ? const Center(
              child: Text(
                'Nenhum registro disponível para visualização.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: dados!.length,
              itemBuilder: (context, index) {
                final item = dados![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/telaDetalhesRegistro',
                      arguments: item,
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registro ${index + 1}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
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
                        ],
                      ),
                    ),
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
