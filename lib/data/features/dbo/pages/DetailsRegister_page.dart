import 'package:flutter/material.dart';
import 'package:senior/data/global_data.dart';

class DetailsregisterPage extends StatefulWidget {
  // Observação: o parâmetro 'registros' é obrigatório, porém neste exemplo
  // utilizamos o global 'listaDeRegistros' para separar os registros.
  const DetailsregisterPage(
      {super.key, required List<Map<String, dynamic>> registros});

  @override
  _DetailsregisterPageState createState() => _DetailsregisterPageState();
}

class _DetailsregisterPageState extends State<DetailsregisterPage> {
  late List<Map<String, dynamic>> registrosPublicos;
  late List<Map<String, dynamic>> registrosAtividades;

  @override
  void initState() {
    super.initState();
    // Separa os registros da primeira tela (que possuem 'matricula')
    // e da segunda tela (que possuem 'operacao').
    registrosPublicos = List<Map<String, dynamic>>.from(listaDeRegistros
        .where((registro) => registro.containsKey('matricula')));
    registrosAtividades = List<Map<String, dynamic>>.from(
        listaDeRegistros.where((registro) => registro.containsKey('operacao')));
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty =
        registrosPublicos.isEmpty && registrosAtividades.isEmpty;
    return Scaffold(
      body: isEmpty
          ? const Center(
              child: Text(
                'Nenhum registro disponível para visualização.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildRegistroSection(
                    "Registros da Primeira Tela", registrosPublicos),
                _buildRegistroSection(
                    "Registros da Segunda Tela", registrosAtividades),
              ],
            ),
    );
  }

  /// Cria uma seção para exibir registros de uma determinada tela.
  Widget _buildRegistroSection(
      String title, List<Map<String, dynamic>> registros) {
    if (registros.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
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
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Cria uma lista de widgets para exibir cada campo do registro com ícone.
  List<Widget> _buildRegistroInfo(Map<String, dynamic> registro) {
    List<Widget> infoWidgets = [];
    registro.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        infoWidgets
            .add(_buildInfoRow(_getIconForKey(key), _formatLabel(key), value));
      }
    });
    return infoWidgets;
  }

  /// Cria uma linha com ícone, rótulo e valor para um campo do registro.
  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
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

  /// Define os ícones a serem utilizados para cada campo.
  IconData _getIconForKey(String key) {
    switch (key) {
      case 'matricula':
        return Icons.badge;
      case 'nomeCoordenador':
        return Icons.person;
      case 'patrimonio':
        return Icons.precision_manufacturing;
      case 'horarioInicial':
        return Icons.timer;
      case 'horarioFinal':
        return Icons.timer_off;
      case 'horimetroInicial':
        return Icons.speed;
      case 'horimetroFinal':
        return Icons.speed;
      case 'patrimonioImplemento':
        return Icons.build;
      case 'operacao':
        return Icons.construction;
      case 'motivo':
        return Icons.warning;
      case 'talhao':
        return Icons.terrain;
      case 'cultura':
        return Icons.agriculture;
      default:
        return Icons.info;
    }
  }

  /// Formata os rótulos para exibição.
  String _formatLabel(String key) {
    switch (key) {
      case 'matricula':
        return 'Matrícula';
      case 'nomeCoordenador':
        return 'Nome do Coordenador';
      case 'patrimonio':
        return 'Patrimônio';
      case 'horarioInicial':
        return 'Horário Inicial';
      case 'horarioFinal':
        return 'Horário Final';
      case 'horimetroInicial':
        return 'Horímetro Inicial';
      case 'horimetroFinal':
        return 'Horímetro Final';
      case 'patrimonioImplemento':
        return 'Patrimônio Implemento';
      case 'operacao':
        return 'Operação';
      case 'motivo':
        return 'Motivo de Parada';
      case 'talhao':
        return 'Talhão';
      case 'cultura':
        return 'Cultura';
      default:
        return key;
    }
  }
}
