import 'package:flutter/material.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/core/repository/exceptions_network.dart';
import 'package:senior/data/views/dbo/pages/LastRegister_page.dart';
import 'package:senior/data/views/widgets/base_layout.dart';

class DetailsregisterPage extends StatefulWidget {
  List<Map<String, dynamic>> registros;

  DetailsregisterPage({
    super.key,
    required this.registros,
  });

  @override
  _DetailsregisterPageState createState() => _DetailsregisterPageState();
}

class _DetailsregisterPageState extends State<DetailsregisterPage> {
  final GetServices getServices = GetServices();
  List<Map<String, dynamic>> concluidos = [];
  List<Map<String, dynamic>> emEspera = [];
  List<Map<String, dynamic>> incompletos = [];
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    concluidos = [];
    emEspera = [];
    incompletos = [];
    fetchBDO();
  }

  void fetchBDO() async {
    try {
      final result = await getServices.getBDO();
      setState(() {
        widget.registros = result;
        _classificarRegistros();
      });
    } catch (error) {
      ErrorNotifier.showError('Erro ao fazer busca de BDO: $error');
    }
  }

  void _classificarRegistros() {
    for (final registro in widget.registros) {
      final status = _determineStatus(registro);
      print('status $status: ');
      switch (status) {
        case 'concluido':
          concluidos.add(registro);
          break;
        case 'Em Andamento':
          emEspera.add(registro);
          break;
        case 'incompleto':
          incompletos.add(registro);
      }
    }
  }

  String _determineStatus(Map<String, dynamic> registro) {
    final status = registro['Status']?.toString().toLowerCase() ?? '';

    if (status == 'concluido') return 'concluido';
    if (status == 'em andamento') return 'Em Andamento';
    return 'incompleto';
  }

  bool get _isAllEmpty =>
      concluidos.isEmpty && emEspera.isEmpty && incompletos.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isAllEmpty ? _buildEmptyState() : _buildContent(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Nenhum registro disponível',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildStatusSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.analytics_outlined, color: Colors.black, size: 32),
          const SizedBox(width: 16),
          Text(
            'Detalhes de Registros',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      children: [
        _buildStatusCard('Concluídos', concluidos, Colors.green),
        const SizedBox(height: 16),
        _buildStatusCard('Em Espera', emEspera, Colors.orange),
        const SizedBox(height: 16),
        _buildStatusCard('Incompletos', incompletos, Colors.red),
      ],
    );
  }

  Widget _buildStatusCard(
      String title, List<Map<String, dynamic>> registros, Color color) {
    final Color softColor = Colors.white; // Card principal branco
    final Color textColor = color.withOpacity(0.9);
    final Color iconColor = color.withOpacity(0.8);

    return Card(
      elevation: 2,
      color: softColor, // Mantém o card branco
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        iconColor: color,
        collapsedIconColor: color.withOpacity(0.6),
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(title),
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$title (${registros.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        children: [
          if (registros.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Nenhum registro',
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              color: Colors.white, // Fundo branco, sem gradiente
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
                      elevation: 0,
                      color: Colors.white, // Card interno também branco
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: color.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap:
                            _isNavigating ? null : () => _onCardTap(registro),
                        child: ExpansionTile(
                          leading: Icon(
                            Icons.list_alt,
                            color: iconColor,
                          ),
                          iconColor: iconColor,
                          title: Text(
                            'Registro ${index + 1}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor.withOpacity(0.9),
                            ),
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
                                          backgroundColor: color,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          elevation: 2,
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

  IconData _getStatusIcon(String title) {
    switch (title) {
      case 'Concluídos':
        return Icons.check_circle;
      case 'Em Espera':
        return Icons.pause_circle;
      case 'Incompletos':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  List<Widget> _buildRegistroInfo(Map<String, dynamic> registro) {
    return [
      _buildInfoSection('Informações Básicas', [
        _buildInfoItem(Icons.badge, 'Matricula', registro['usuarioId']),
        _buildInfoItem(Icons.badge, 'Operador', registro['operador']),
        _buildInfoItem(
            Icons.timer, 'Horário Inicial', registro['jornadaInicial']),
        _buildInfoItem(
            Icons.timer_off, 'Horário Final', registro['jornadaFinal']),
      ]),
      const Divider(height: 24, color: Colors.grey),
      _buildInfoSection('Detalhes Operacionais', [
        _buildInfoItem(
            Icons.precision_manufacturing, 'Patrimônio', registro['bem']),
        _buildInfoItem(Icons.construction, 'Operação', registro['servico']),
        _buildInfoItem(
            Icons.speed, 'Horímetro Inicial', registro['horimentro_inicial']),
        _buildInfoItem(
            Icons.speed, 'Horímetro Final', registro['horimentro_fim']),
        if (registro.containsKey('tempoTrabalhado'))
          _buildInfoItem(Icons.access_time, 'Horas Trabalhadas',
              registro['tempoTrabalhado']),
        if (registro.containsKey('horimetroTotal'))
          _buildInfoItem(
              Icons.timelapse, 'Horas Máquina', registro['horimetroTotal']),
        if (registro.containsKey('areaTrabalhada'))
          _buildInfoItem(
              Icons.terrain, 'Área Trabalhada', registro['areaTrabalhada']),
      ]),
      const Divider(height: 24, color: Colors.grey),
      _buildMotivosParadaSection(registro),
    ];
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),
        ),
        ...items,
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.blue[800]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value?.toString() ?? 'Não informado',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black, // letras pretas
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivosParadaSection(Map<String, dynamic> registro) {
    if (!registro.containsKey('motivosParada')) return const SizedBox.shrink();

    final motivos = registro['motivosParada'] as List;
    if (motivos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Motivos de Parada',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 8),
        ...motivos.map<Widget>((mp) => _buildMotivoItem(mp)).toList(),
      ],
    );
  }

  Widget _buildMotivoItem(Map<String, dynamic> motivo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.orange[800]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  motivo['descricao'] ?? 'Motivo não informado',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildDetailRow('Início:', motivo['inicio']),
          _buildDetailRow('Fim:', motivo['fim']),
          if (motivo['duracaoMin'] != null)
            _buildDetailRow('Duração:', '${motivo['duracaoMin']} min'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
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
          'Deseja concluir este registro? Ele não poderá mais ser alterado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                registro['status'] = 'concluido';
                _classificarRegistros();
              });
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _onCardTap(Map<String, dynamic> registro) async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      if (_determineStatus(registro) == 'concluido') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro concluído não pode ser alterado'),
          ),
        );
        return;
      }

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BaseLayout(body: LastRegisterPage(registro: registro)),
        ),
      );
    } finally {
      _isNavigating = false;
    }
  }
}
