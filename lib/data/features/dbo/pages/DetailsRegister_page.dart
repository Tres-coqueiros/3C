import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior/data/app_database.dart';
//import 'package:senior/data/database/app_database.dart';

class DetailsregisterPage extends StatefulWidget {
  const DetailsregisterPage({super.key, required List registros});

  @override
  _DetailsregisterPageState createState() => _DetailsregisterPageState();
}

class _DetailsregisterPageState extends State<DetailsregisterPage> {
  late Future<List<Atividade>> _futureRegistros;

  @override
  void initState() {
    super.initState();
    _futureRegistros = _carregarRegistros();
  }

  /// **Obtém os registros do banco Drift**
  Future<List<Atividade>> _carregarRegistros() async {
    final database = Provider.of<AppDatabase>(context, listen: false);
    return await database.obterAtividades();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Registros'),
        backgroundColor: Colors.green[800],
      ),
      body: FutureBuilder<List<Atividade>>(
        future: _futureRegistros,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum registro disponível para visualização.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            );
          }

          final registros = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: registros.length,
            itemBuilder: (context, index) {
              final registro = registros[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  leading: const Icon(Icons.list_alt, color: Colors.blue),
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
                        children: _buildRegistroInfo(registro),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[800],
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

  /// **Cria uma lista de widgets para exibir os detalhes do registro**
  List<Widget> _buildRegistroInfo(Atividade registro) {
    return [
      _buildInfoRow(Icons.badge, 'Matrícula', registro.descricao),
      _buildInfoRow(Icons.person, 'Nome do Coordenador', registro.coordenador),
      _buildInfoRow(
          Icons.precision_manufacturing, 'Patrimônio', registro.patrimonio),
      _buildInfoRow(Icons.timer, 'Horário Inicial', registro.horarioInicial),
      _buildInfoRow(Icons.timer_off, 'Horário Final', registro.horarioFinal),
      _buildInfoRow(
          Icons.speed, 'Horímetro Inicial', registro.horimetroInicial),
      _buildInfoRow(Icons.speed, 'Horímetro Final', registro.horimetroFinal),
    ];
  }

  /// **Cria uma linha com ícone, rótulo e valor**
  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: ${value ?? 'Não informado'}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
