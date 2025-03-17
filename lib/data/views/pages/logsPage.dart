import 'package:flutter/material.dart';
import 'package:senior/data/core/interface/app_interface.dart';
import 'package:senior/data/core/repository/api_repository.dart';

class Logspage extends StatefulWidget {
  const Logspage({Key? key}) : super(key: key);

  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<Logspage> {
  final GetServices getServices = GetServices();

  // Lista original e lista filtrada
  List<LogEntry> allLogs = [];
  List<LogEntry> filteredLogs = [];

  // Armazena texto digitado no campo de busca (comentei o TextField para filtrar por texto)
  String _searchQuery = '';

  // Armazena o tipo de log selecionado
  String _selectedType = 'Todos';

  // Exemplos de tipos possíveis (ajuste conforme seu app)
  final List<String> _logTypes = [
    'Todos',
    'LOGIN',
    'SOLICITAÇÃO ENVIADA',
    'BDO',
    'OUTRO'
  ];

  // ==========================
  // Filtros de data
  // ==========================
  DateTime? _startDate; // Data inicial
  DateTime? _endDate; // Data final

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  void fetchLogs() async {
    try {
      final result = await getServices.getLogs();
      setState(() {
        allLogs = result.map((logs) {
          return LogEntry(
            usuario: logs['usuario_id'],
            atividade: logs['tipo'].toString(),
            descricao: logs['mensagem'].toString(),
            dataHora: DateTime.parse(logs['data'].toString()),
          );
        }).toList();

        // Inicialmente exibe todos
        filteredLogs = List.from(allLogs);
      });
    } catch (error) {
      print('Erro ao carregar atividades: $error');
    }
  }

  /// Filtra a lista de logs de acordo com:
  /// - o tipo selecionado (_selectedType)
  /// - o texto (comentado no TextField)
  /// - o intervalo de datas (_startDate, _endDate)
  void _applyFilters() {
    setState(() {
      filteredLogs = allLogs.where((log) {
        // Filtro por tipo
        final matchesType =
            (_selectedType == 'Todos') || (log.atividade == _selectedType);

        // Filtro por texto (se quiser reativar o TextField de busca)
        final matchesSearch = _searchQuery.isEmpty ||
            log.descricao.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            log.atividade.toLowerCase().contains(_searchQuery.toLowerCase());

        // Filtro por data
        final matchesDate =
            (_startDate == null || log.dataHora.isAfter(_startDate!)) &&
                (_endDate == null || log.dataHora.isBefore(_endDate!));

        return matchesType && matchesSearch && matchesDate;
      }).toList();
    });
  }

  /// Botão "Limpar" que zera datas e tipo, voltando a mostrar tudo
  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedType = 'Todos';
      // Se tiver _searchQuery, também zere:
      // _searchQuery = '';
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Barra de busca e dropdown de tipo + botão Limpar
          _buildSearchBar(context),

          // Filtros de data (início e fim)
          _buildDateFilters(context),

          Expanded(
            child: filteredLogs.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum registro de atividade encontrado.',
                      style:
                          TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return _buildLogItem(log);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Barra de busca e dropdown de tipo + botão "Limpar"
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // (Descomente se quiser o campo de busca por texto)
          /*
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Pesquisar...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
            ),
          ),
          SizedBox(width: 8),
          */

          // Dropdown para selecionar tipo de log
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              value: _selectedType,
              items: _logTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Tipo',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
              onChanged: (value) {
                if (value != null) {
                  _selectedType = value;
                  _applyFilters();
                }
              },
            ),
          ),

          const SizedBox(width: 8),

          // Botão LIMPAR
          ElevatedButton.icon(
            onPressed: _clearFilters,
            style: ElevatedButton.styleFrom(
              shadowColor: Colors.red, // Cor de fundo do botão
              overlayColor: Colors.white, // Cor do texto e ícone
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0), // Bordas arredondadas
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 8.0), // Espaçamento interno
            ),
            // icon: const Icon(Icons.clear,
            //     color: Color.fromARGB(255, 195, 11, 11)), // Ícone "X" branco
            label: const Text('LIMPAR',
                style: TextStyle(color: Colors.white)), // Texto branco
          ),
        ],
      ),
    );
  }

  /// Constrói o card de cada log
  Widget _buildLogItem(LogEntry log) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.receipt_long),
        title: Text(
          '${log.atividade} -${log.usuario}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data/Hora: ${_formatDateTime(log.dataHora)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(log.descricao),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final dia = dt.day.toString().padLeft(2, '0');
    final mes = dt.month.toString().padLeft(2, '0');
    final ano = dt.year;
    final hora = dt.hour.toString().padLeft(2, '0');
    final minuto = dt.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano $hora:$minuto';
  }

  /// Seção: Filtros de Data (Data Inicial e Data Final)
  Widget _buildDateFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          // Botão para escolher data inicial
          Expanded(
            child: InkWell(
              onTap: () => _pickDate(context, isStart: true),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _startDate == null
                      ? 'Data Inicial'
                      : 'Início: ${_formatDateTime(_startDate!)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botão para escolher data final
          Expanded(
            child: InkWell(
              onTap: () => _pickDate(context, isStart: false),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _endDate == null
                      ? 'Data Final'
                      : 'Fim: ${_formatDateTime(_endDate!)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Abre um DatePicker para selecionar data inicial ou final
  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final initialDate =
        isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (newDate != null) {
      setState(() {
        if (isStart) {
          _startDate = DateTime(newDate.year, newDate.month, newDate.day, 0, 0);
        } else {
          _endDate = DateTime(newDate.year, newDate.month, newDate.day, 23, 59);
        }
      });
      _applyFilters();
    }
  }
}
