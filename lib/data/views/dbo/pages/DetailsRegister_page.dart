import 'package:flutter/material.dart';
import 'package:senior/data/global_data.dart';

class DetailsregisterPage extends StatefulWidget {
  const DetailsregisterPage(
      {super.key, required List<Map<String, dynamic>> registros});

  @override
  _DetailsregisterPageState createState() => _DetailsregisterPageState();
}

class _DetailsregisterPageState extends State<DetailsregisterPage> {
  late List<Map<String, dynamic>> concluidos;
  late List<Map<String, dynamic>> emEspera;
  late List<Map<String, dynamic>> incompletos;

  @override
  void initState() {
    super.initState();
    concluidos = [];
    emEspera = [];
    incompletos = [];

    // Classifica cada registro em um dos três status:
    for (final registro in listaDeRegistros) {
      final status = _determineStatus(registro);
      if (status == 'concluido') {
        concluidos.add(registro);
      } else if (status == 'emEspera') {
        emEspera.add(registro);
      } else {
        incompletos.add(registro);
      }
    }
  }

  /// Determina o status de cada registro:
  /// - "concluido" (verde) => matricula != null, operacao != null e 'motivosParada' não vazio
  /// - "incompleto" (vermelho) => não tem ou está vazio 'motivosParada'
  /// - "emEspera" (amarelo) => todo o resto
  String _determineStatus(Map<String, dynamic> registro) {
    final matricula = registro['matricula'] ?? '';
    final operacao = registro['operacao'] ?? '';
    final motivosParada = registro['motivosParada'];

    // Se não tem motivos de parada ou está vazio => "incompleto" (vermelho)
    if (motivosParada == null ||
        (motivosParada is List && motivosParada.isEmpty)) {
      return 'incompleto';
    }
    // Se tudo preenchido => "concluido" (verde)
    if (matricula.toString().isNotEmpty && operacao.toString().isNotEmpty) {
      return 'concluido';
    }
    // Caso contrário => "emEspera" (amarelo)
    return 'emEspera';
  }

  @override
  Widget build(BuildContext context) {
    final bool isAllEmpty =
        concluidos.isEmpty && emEspera.isEmpty && incompletos.isEmpty;

    return Scaffold(
      // Removemos o AppBar e colocamos o título direto no body
      body: SafeArea(
        child: isAllEmpty
            ? const Center(
                child: Text(
                  'Nenhum registro disponível para visualização.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Título simples no topo
                    const Text(
                      'Detalhes de Registros',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Card para registros Concluídos (Verde)
                    _buildStatusCard(
                      'Registros Concluídos',
                      concluidos,
                      Colors.green[100] ?? Colors.greenAccent,
                    ),
                    const SizedBox(height: 16),
                    // Card para registros em Espera (Amarelo)
                    _buildStatusCard(
                      'Registros em Espera',
                      emEspera,
                      Colors.yellow[100] ?? Colors.yellowAccent,
                    ),
                    const SizedBox(height: 16),
                    // Card para registros Incompletos (Vermelho)
                    _buildStatusCard(
                      'Registros Incompletos',
                      incompletos,
                      Colors.red[100] ?? Colors.redAccent,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatusCard(
      String title, List<Map<String, dynamic>> registros, Color color) {
    return Card(
      color: color,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
        title: Text(
          '$title (${registros.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        children: [
          if (registros.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Nenhum registro'),
            )
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: registros.length,
                  itemBuilder: (context, index) {
                    final registro = registros[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        onTap: () => _onCardTap(registro),
                        child: ExpansionTile(
                          leading:
                              const Icon(Icons.list_alt, color: Colors.blue),
                          title: Text(
                            'Registro ${index + 1}',
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _buildRegistroInfo(registro),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildRegistroInfo(Map<String, dynamic> registro) {
    final List<Widget> infoWidgets = [];

    infoWidgets.add(const Text(
      'Estado 1 (Primeira Tela)',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ));
    infoWidgets.add(_buildInfoRow(_getIconForKey('matricula'),
        _formatLabel('matricula'), registro['matricula']));
    infoWidgets.add(_buildInfoRow(_getIconForKey('horarioInicial'),
        _formatLabel('horarioInicial'), registro['horarioInicial']));
    infoWidgets.add(_buildInfoRow(_getIconForKey('horarioFinal'),
        _formatLabel('horarioFinal'), registro['horarioFinal']));

    infoWidgets.add(const SizedBox(height: 8));
    infoWidgets.add(const Divider());
    infoWidgets.add(const SizedBox(height: 8));

    infoWidgets.add(const Text(
      'Estado 2 (Segunda Tela)',
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ));
    infoWidgets.add(_buildInfoRow(_getIconForKey('patrimonio'),
        _formatLabel('patrimonio'), registro['patrimonio']));
    infoWidgets.add(_buildInfoRow(_getIconForKey('operacao'),
        _formatLabel('operacao'), registro['operacao']));
    infoWidgets.add(_buildInfoRow(_getIconForKey('horimetroInicial'),
        _formatLabel('horimetroInicial'), registro['horimetroInicial']));
    infoWidgets.add(_buildInfoRow(_getIconForKey('horimetroFinal'),
        _formatLabel('horimetroFinal'), registro['horimetroFinal']));

    // Motivos de parada
    if (registro.containsKey('motivosParada') &&
        registro['motivosParada'] is List) {
      final motivos = registro['motivosParada'] as List;
      if (motivos.isNotEmpty) {
        infoWidgets.add(
          const Padding(
            padding: EdgeInsets.only(top: 12.0, bottom: 6.0),
            child: Text(
              'Motivos de Parada:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        );
        for (int i = 0; i < motivos.length; i++) {
          final mp = motivos[i] as Map<String, dynamic>;
          infoWidgets.add(
            Container(
              margin: const EdgeInsets.only(left: 16, bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ${mp['descricao'] ?? 'Motivo não informado'}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text('Início: ${mp['inicio'] ?? 'Não informado'}',
                      style: const TextStyle(fontSize: 13)),
                  Text('Fim: ${mp['fim'] ?? 'Não informado'}',
                      style: const TextStyle(fontSize: 13)),
                  if (mp['duracaoMin'] != null)
                    Text('Tempo parado: ${mp['duracaoMin']} min',
                        style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          );
        }
      } else {
        infoWidgets.add(_buildInfoRow(
            _getIconForKey('motivosParada'),
            _formatLabel('motivosParada'),
            'Nenhum motivo de parada cadastrado'));
      }
    } else {
      infoWidgets.add(_buildInfoRow(_getIconForKey('motivosParada'),
          _formatLabel('motivosParada'), 'Nenhum motivo de parada cadastrado'));
    }

    return infoWidgets;
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: ${value ?? 'Não informado'}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

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
      case 'motivosParada':
        return Icons.warning;
      case 'talhao':
        return Icons.terrain;
      case 'cultura':
        return Icons.agriculture;
      default:
        return Icons.info;
    }
  }

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
      case 'motivosParada':
        return 'Motivos de Parada';
      case 'talhao':
        return 'Talhão';
      case 'cultura':
        return 'Cultura';
      default:
        return key;
    }
  }

  void _onCardTap(Map<String, dynamic> registro) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detalhes / Editar Motivos'),
        content: const Text(
          'Aqui você poderia redirecionar para uma tela read-only, \n'
          'habilitando apenas a edição de motivos de parada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
