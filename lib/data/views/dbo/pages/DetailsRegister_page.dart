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

  /// Listas separadas de registros
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

  /// Classifica os registros em três listas e
  /// inicializa cada registro com `selected = false`.
  void _classificarRegistros() {
    // Limpa as listas antes de popular
    concluidos.clear();
    emEspera.clear();
    incompletos.clear();

    for (final registro in widget.registros) {
      // Adiciona a chave de seleção para cada registro (inicialmente false)
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

  /// Determina o status textual de cada registro
  String _determineStatus(Map<String, dynamic> registro) {
    final status = registro['Status']?.toString().toLowerCase() ?? '';
    if (status == 'concluido') return 'concluido';
    if (status == 'em andamento') return 'Em Andamento';
    return 'incompleto';
  }

  /// Verifica se todas as listas estão vazias
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

  /// Monta as três seções: Concluídos, Em Espera, Incompletos
  Widget _buildStatusSection() {
    return Column(
      children: [
        // 1) Concluídos (SEM checkboxes)
        _buildStatusCard('Concluídos', concluidos, Colors.green,
            showCheckboxes: false),
        const SizedBox(height: 16),
        // 2) Em Espera (COM checkboxes)
        _buildStatusCard('Em Espera', emEspera, Colors.orange,
            showCheckboxes: true),
        const SizedBox(height: 16),
        // 3) Incompletos (SEM checkboxes)
        _buildStatusCard('Incompletos', incompletos, Colors.red,
            showCheckboxes: false),
      ],
    );
  }

  /// Constrói cada seção (Card + ExpansionTile)
  /// Se `showCheckboxes` for true, exibe checkbox geral e individual
  Widget _buildStatusCard(
    String title,
    List<Map<String, dynamic>> registros,
    Color color, {
    required bool showCheckboxes,
  }) {
    final Color softColor = Colors.white; // Card principal branco
    final Color textColor = color.withOpacity(0.9);
    final Color iconColor = color.withOpacity(0.8);

    // Se a seção permite checkboxes, verifica se todos estão selecionados
    final bool allSelected = showCheckboxes &&
        registros.isNotEmpty &&
        registros.every((r) => (r['selected'] as bool?) == true);

    return Card(
      elevation: 2,
      color: softColor,
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

        /// Cabeçalho da seção
        title: Row(
          children: [
            // Ícone colorido circular
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
            // Título + quantidade
            Text(
              '$title (${registros.length})',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),

            // Checkbox geral só se showCheckboxes = true
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
              ),
          ],
        ),

        /// Conteúdo da seção (lista de registros)
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
              color: Colors.white, // Fundo branco
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
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: color.withOpacity(0.1),
                          width: 1,
                        ),
                      ),

                      /// Cada registro em si
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap:
                            _isNavigating ? null : () => _onCardTap(registro),

                        /// O registro também é um ExpansionTile
                        child: ExpansionTile(
                          leading: Icon(
                            Icons.list_alt,
                            color: iconColor,
                          ),

                          // Só mostra checkbox individual se showCheckboxes = true
                          trailing: showCheckboxes
                              ? Checkbox(
                                  value:
                                      (registro['selected'] as bool?) ?? false,
                                  onChanged: (bool? val) {
                                    setState(() {
                                      registro['selected'] = val ?? false;
                                    });
                                  },
                                )
                              : null,

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

  /// Define o ícone do cabeçalho da seção
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

  /// Monta as seções de informações de cada registro
  List<Widget> _buildRegistroInfo(Map<String, dynamic> registro) {
    final status = _determineStatus(registro);
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
                    color: Colors.black,
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

  /// Botão "Concluir" de um registro em Em Espera
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

  /// Ao tocar num registro, abre a tela LastRegisterPage
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
