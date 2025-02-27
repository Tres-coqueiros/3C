import 'package:flutter/material.dart';
import 'package:senior/data/global_data.dart';
import 'package:senior/data/views/dbo/pages/LastRegister_page.dart';

class DetailsregisterPage extends StatefulWidget {
  const DetailsregisterPage({
    super.key,
    required List<Map<String, dynamic>> registros,
  });

  @override
  _DetailsregisterPageState createState() => _DetailsregisterPageState();
}

class _DetailsregisterPageState extends State<DetailsregisterPage> {
  // Listas para cada status
  late List<Map<String, dynamic>> concluidos;
  late List<Map<String, dynamic>> emEspera;
  late List<Map<String, dynamic>> incompletos;

  // Flag para evitar múltiplos cliques rápidos
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    concluidos = [];
    emEspera = [];
    incompletos = [];

    // Classifica cada registro do listaDeRegistros
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

  /// Determina o status de cada registro
  String _determineStatus(Map<String, dynamic> registro) {
    if (registro['status'] == 'concluido') {
      return 'concluido';
    }

    final matricula = registro['matricula'] ?? '';
    final operacao = registro['operacao'] ?? '';
    final motivosParada = registro['motivosParada'];

    if (motivosParada == null ||
        (motivosParada is List && motivosParada.isEmpty)) {
      return 'incompleto';
    }
    if (matricula.toString().isNotEmpty && operacao.toString().isNotEmpty) {
      return 'concluido';
    }
    return 'emEspera';
  }

  @override
  Widget build(BuildContext context) {
    final bool isAllEmpty =
        concluidos.isEmpty && emEspera.isEmpty && incompletos.isEmpty;

    return Scaffold(
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
                    const Text(
                      'Detalhes de Registros',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatusCard(
                        'Registros Concluídos', concluidos, Colors.green[100]!),
                    const SizedBox(height: 16),
                    _buildStatusCard(
                        'Registros em Espera', emEspera, Colors.yellow[100]!),
                    const SizedBox(height: 16),
                    _buildStatusCard(
                        'Registros Incompletos', incompletos, Colors.red[100]!),
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
                    final status = _determineStatus(registro);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        // Se _isNavigating == true, onTap fica null (desabilita clique)
                        onTap:
                            _isNavigating ? null : () => _onCardTap(registro),
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
                                children: [
                                  ..._buildRegistroInfo(registro),
                                  if (status == 'emEspera')
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () =>
                                            _concluirRegistro(registro),
                                        child: const Text('Concluir'),
                                      ),
                                    ),
                                ],
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

    // Estado 1
    infoWidgets.add(const Text('Estado 1 (Primeira Tela)',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)));
    infoWidgets
        .add(_buildInfoRow(Icons.badge, 'Matrícula', registro['matricula']));
    infoWidgets.add(_buildInfoRow(
        Icons.timer, 'Horário Inicial', registro['horarioInicial']));
    infoWidgets.add(_buildInfoRow(
        Icons.timer_off, 'Horário Final', registro['horarioFinal']));

    infoWidgets.add(const SizedBox(height: 8));
    infoWidgets.add(const Divider());
    infoWidgets.add(const SizedBox(height: 8));

    // Estado 2
    infoWidgets.add(const Text('Estado 2 (Segunda Tela)',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)));
    infoWidgets.add(_buildInfoRow(
        Icons.precision_manufacturing, 'Patrimônio', registro['patrimonio']));
    infoWidgets.add(
        _buildInfoRow(Icons.construction, 'Operação', registro['operacao']));
    infoWidgets.add(_buildInfoRow(
        Icons.speed, 'Horímetro Inicial', registro['horimetroInicial']));
    infoWidgets.add(_buildInfoRow(
        Icons.speed, 'Horímetro Final', registro['horimetroFinal']));

    // Total de Horas Trabalhadas (tempoTrabalhado)
    if (registro.containsKey('tempoTrabalhado')) {
      infoWidgets.add(
        _buildInfoRow(
          Icons.access_time,
          'Total de Horas Trabalhadas',
          registro['tempoTrabalhado'],
        ),
      );
    }

    // Total de Horas de Máquina (horimetroTotal)
    if (registro.containsKey('horimetroTotal')) {
      infoWidgets.add(
        _buildInfoRow(
          Icons.timelapse,
          'Total de Horas de Máquina',
          registro['horimetroTotal'],
        ),
      );
    }

    // Área Trabalhada (areaTrabalhada)
    if (registro.containsKey('areaTrabalhada')) {
      infoWidgets.add(
        _buildInfoRow(
          Icons.terrain, // escolhemos um ícone de terreno, por exemplo
          'Área Trabalhada',
          registro['areaTrabalhada'],
        ),
      );
    }

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
                    Text(
                      'Tempo parado: ${mp['duracaoMin']} min',
                      style: const TextStyle(fontSize: 13),
                    ),
                ],
              ),
            ),
          );
        }
      } else {
        infoWidgets.add(
          _buildInfoRow(
            Icons.warning,
            'Motivos de Parada',
            'Nenhum motivo de parada cadastrado',
          ),
        );
      }
    } else {
      infoWidgets.add(
        _buildInfoRow(
          Icons.warning,
          'Motivos de Parada',
          'Nenhum motivo de parada cadastrado',
        ),
      );
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

  void _concluirRegistro(Map<String, dynamic> registro) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Concluir Registro'),
        content: const Text(
          'Deseja concluir este registro? Ele não poderá mais ser alterado, nem o motivo de parada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                registro['status'] = 'concluido';
              });
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  // Transformamos em async e usamos await
  Future<void> _onCardTap(Map<String, dynamic> registro) async {
    final status = _determineStatus(registro);

    if (status == 'concluido') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Este registro já está concluído e não pode ser alterado.'),
        ),
      );
      return;
    }

    // Se já estamos navegando, sai imediatamente
    if (_isNavigating) return;
    _isNavigating = true;

    // Aguarda a rota terminar
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LastRegisterPage(registro: registro),
      ),
    );

    // Libera novamente
    _isNavigating = false;
  }
}
