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
  final UpdateServices updateServices = UpdateServices();
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

  void _salvarAlteracoes() async {
    final data = {
      'producao_id': int.tryParse(widget.registros[0]['id'].toString()),
      "operador_id":
          int.tryParse(widget.registros[0]['operador_id'].toString()),
      "safra_id": int.tryParse(widget.registros[0]['safra_id'].toString()),
      "talhao_id": int.tryParse(widget.registros[0]['talhao_id'].toString()),
      "fazenda": widget.registros[0]['unidade'],
      "cultura_id": int.tryParse(widget.registros[0]['cultura_id'].toString()),
      "ciclo_id": int.tryParse(widget.registros[0]['ciclo_id'].toString()),
      "unidade_id": int.tryParse(widget.registros[0]['unidade_id'].toString()),
      "areaTalhao": widget.registros[0]['safra'],
      "areaTrabalhada": widget.registros[0]['areaTrabalhada'],
      "JornadaInicial": widget.registros[0]['jornadaInicial'],
      "JornadaFinal": widget.registros[0]['jornadaFinal'],
    };
    final success = await updateServices.updateBDO(data);
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => DetailsregisterPage(registros: widget.registros)),
      );
    }
  }

  void fetchBDO() async {
    try {
      final result = await getServices.getBDO();
      setState(() {
        widget.registros = result.map((producao) {
          final producaoSemRegistros = Map<String, dynamic>.from(producao);
          return producaoSemRegistros;
        }).toList();
        _classificarRegistros();
      });
    } catch (error) {
      ErrorNotifier.showError('Erro ao fazer busca de BDO: $error');
    }
  }

  void _classificarRegistros() {
    concluidos.clear();
    emEspera.clear();
    incompletos.clear();

    for (final registro in widget.registros) {
      registro['selected'] = false;

      final status = _determineStatus(registro);
      switch (status) {
        case 'concluido':
          concluidos.add(registro);
          break;
        case 'Em Andamento':
          emEspera.add(registro);
          break;
        case 'incompleto':
          incompletos.add(registro);
          break;
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
        _buildStatusCard(
          'Concluídos',
          concluidos,
          Colors.green,
          showCheckboxes: false,
        ),
        const SizedBox(height: 16),
        _buildStatusCard(
          'Em Espera',
          emEspera,
          Colors.orange,
          showCheckboxes: true,
        ),
        const SizedBox(height: 16),
        _buildStatusCard(
          'Incompletos',
          incompletos,
          Colors.red,
          showCheckboxes: false,
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    String title,
    List<Map<String, dynamic>> registros,
    Color color, {
    required bool showCheckboxes,
  }) {
    final bool allSelected = showCheckboxes &&
        registros.isNotEmpty &&
        registros.every((r) => (r['selected'] as bool?) == true);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                color: color.withOpacity(0.9),
              ),
            ),
            const Spacer(),
            if (showCheckboxes)
              Checkbox(
                value: allSelected,
                onChanged: (bool? val) {
                  setState(() {
                    final newVal = val ?? false;
                    for (var r in registros) {
                      r['selected'] = newVal;
                    }
                  });
                },
                fillColor: MaterialStateProperty.resolveWith<Color>(
                  (states) => color, // Cor do checkbox
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
                  color: color.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: registros.length,
                itemBuilder: (context, index) {
                  final registro = registros[index];

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: color.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _onCardTap(registro),
                      child: ExpansionTile(
                        leading: Icon(
                          Icons.list_alt,
                          color: color.withOpacity(0.8),
                        ),
                        trailing: showCheckboxes
                            ? Checkbox(
                                value: (registro['selected'] as bool?) ?? false,
                                onChanged: (bool? val) {
                                  setState(() {
                                    registro['selected'] = val ?? false;
                                  });
                                },
                                fillColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                  (states) => color,
                                ),
                              )
                            : null,
                        title: Text(
                          'Registro ${index + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: color.withOpacity(0.9),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ..._buildRegistroInfo(registro),
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
        _buildInfoItem(Icons.timer_off, 'Status', registro['Status']),
      ]),
      const Divider(height: 24, color: Colors.grey),
      _buildInfoSection('Detalhes Operacionais', [
        _buildInfoItem(
            Icons.precision_manufacturing, 'Safra', registro['safra']),
        _buildInfoItem(Icons.construction, 'Cultura', registro['cultura']),
        _buildInfoItem(Icons.speed, 'Talhão', registro['talhao']),
        _buildInfoItem(Icons.speed, 'Unidade', registro['unidade']),
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
