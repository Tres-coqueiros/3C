import 'package:flutter/material.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/views/widgets/components/search_components.dart'; // <-- Aqui está nosso SearchableDropdown

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

  // Em vez de _searchQuery, vamos usar a seleção do dropdown
  // e/ou a string digitada no SearchableDropdown.

  // Armazena o tipo de log selecionado
  String _selectedType = 'Todos';

  // Exemplos de tipos possíveis (ajuste conforme seu app)
  final List<String> _logTypes = [
    'Todos',
    'LOGIN',
    'SOLICITAÇÃO ENVIADA',
    'BDO',
    'OUTRO',
  ];

  // Filtros de data
  DateTime? _startDate;
  DateTime? _endDate;

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

  /// Aplica os filtros: _selectedType, datas etc.
  void _applyFilters({
    String? searchQuery,
  }) {
    setState(() {
      filteredLogs = allLogs.where((log) {
        // 1) Filtro por tipo (dropdown normal)
        final matchesType =
            (_selectedType == 'Todos') || (log.atividade == _selectedType);

        // 2) Filtro por texto (caso o SearchableDropdown retorne algo)
        bool matchesSearch = true;
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final lower = searchQuery.toLowerCase();
          final usuario = log.usuario.toString().toLowerCase();
          final atividade = log.atividade.toLowerCase();
          final descricao = log.descricao.toLowerCase();

          matchesSearch = usuario.contains(lower) ||
              atividade.contains(lower) ||
              descricao.contains(lower);
        }

        // 3) Filtro por data
        final matchesDate =
            (_startDate == null || log.dataHora.isAfter(_startDate!)) &&
                (_endDate == null || log.dataHora.isBefore(_endDate!));

        return matchesType && matchesSearch && matchesDate;
      }).toList();
    });
  }

  /// Limpa todos os filtros
  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedType = 'Todos';
    });
    // Chama _applyFilters sem texto
    _applyFilters(searchQuery: '');
  }

  /// Escolher datas
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Atividades'),
      ),
      body: Column(
        children: [
          // SEÇÃO DE FILTROS
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // 1) Substituímos o TextField por SearchableDropdown
                //    Esse dropdown vai permitir que o usuário digite para filtrar
                //    e retorne uma string selecionada. A cada digitação, chamamos _applyFilters.
                SearchableDropdown(
                  items: allLogs.isEmpty
                      // se não tiver logs ainda, manda uma lista vazia
                      ? []
                      // se tiver logs, gera lista de strings
                      : allLogs
                          .map((e) => '${e.usuario} - ${e.atividade}')
                          .toSet()
                          .toList(), // toSet() remove duplicados
                  itemLabel: (item) => item,
                  labelText: 'Pesquisar usuário/atividade/descrição',
                  onItemSelected: (selecionado) {
                    // Se o usuário realmente clicou em um item,
                    // podemos filtrar usando esse texto
                    _applyFilters(searchQuery: selecionado);
                  },
                ),
                const SizedBox(height: 8),

                // 2) Filtros de data
                Row(
                  children: [
                    // Data Inicial
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
                    // Data Final
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
                const SizedBox(height: 8),

                // 3) Dropdown de tipo
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  items: _logTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      _selectedType = value;
                      // Chama sem texto de busca
                      _applyFilters();
                    }
                  },
                ),
                const SizedBox(height: 8),

                // 4) Botão LIMPAR
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _clearFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    icon: const Icon(Icons.clear, color: Colors.white),
                    label: const Text(
                      'LIMPAR',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // LISTA DE LOGS
          Expanded(
            child: filteredLogs.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum registro de atividade encontrado.',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
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

  /// Constrói cada item do log
  Widget _buildLogItem(LogEntry log) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.receipt_long),
        title: Text(
          '${log.atividade} - ${log.usuario}',
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
}

class LogEntry {
  final dynamic usuario;
  final String atividade;
  final String descricao;
  final DateTime dataHora;

  LogEntry({
    required this.usuario,
    required this.atividade,
    required this.descricao,
    required this.dataHora,
  });
}
