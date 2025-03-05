import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/views/dbo/pages/DetailsRegister_page.dart';

class LastRegisterPage extends StatefulWidget {
  final Map<String, dynamic> registro;

  const LastRegisterPage({super.key, required this.registro});

  @override
  State<LastRegisterPage> createState() => _LastRegisterPageState();
}

class _LastRegisterPageState extends State<LastRegisterPage> {
  final PostServices postServices = PostServices();
  final UpdateServices updateServices = UpdateServices();
  final TextEditingController _novoMotivoController = TextEditingController();
  final TextEditingController _horimetroFinalController =
      TextEditingController();
  final DateFormat _dateFormat = DateFormat('yy/dd/MMMM HH:mm');

  List<dynamic> _motivosParada = [];
  late bool _isConcluido;
  late bool _isHorimetroFinalPreenchido;

  @override
  void initState() {
    super.initState();
    _loadMotivos();
    _isConcluido = widget.registro['Status'] == 'concluido';
    _horimetroFinalController.text =
        widget.registro['horimetroFinal']?.toString() ?? '';
    _isHorimetroFinalPreenchido = widget.registro['horimetroFinal'] != null;
  }

  Future<void> _loadMotivos() async {
    final prefs = await SharedPreferences.getInstance();
    final motivosString = prefs.getString('motivosParada');
    if (motivosString != null) {
      setState(() {
        _motivosParada = List.from(motivosString.split(','));
      });
    } else {
      setState(() {
        _motivosParada = [];
      });
    }
  }

  // Save motivos to SharedPreferences
  Future<void> _saveMotivos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('motivosParada', _motivosParada.join(','));
  }

  Future<DateTime?> _pickDateTime() async {
    DateTime? selecionado;
    await DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onConfirm: (date) => selecionado = date,
      currentTime: DateTime.now(),
      locale: LocaleType.pt,
    );
    return selecionado;
  }

  Future<void> _addNovoMotivo() async {
    final descricao = _novoMotivoController.text.trim();
    final inicio = await _pickDateTime();
    if (inicio == null) return;

    final fim = await _pickDateTime();
    if (fim == null || fim.isBefore(inicio)) return;

    final novoMotivo = {
      'descricao': descricao,
      'inicio': _dateFormat.format(inicio),
      'fim': _dateFormat.format(fim),
      'horimetroFinal': _horimetroFinalController.text,
      'horimentroInicial': widget.registro['horimetro_inicial'],
      'servico': widget.registro['servico'],
      'bem': widget.registro['bem'],
      'producao_id': widget.registro['producao_id'],
    };

    print('novoMotivo $novoMotivo');

    final response = await postServices.postBDOMotivo(novoMotivo);
    if (response['success']) {
      final addMotivo = response['motivo'];
      print(addMotivo);
      setState(() {
        _motivosParada.add(addMotivo);
        _novoMotivoController.clear();
      });
    } else {
      print('Erro ao adicionar motivo: ${response['message']}');
    }
  }

  Future<void> _addHorimetroFinal() async {
    final statusHorimetro = "Horimetro";

    final novoHorimetro = {
      'horimetroFinal': _horimetroFinalController.text,
      'producao_id': widget.registro['producao_id'],
      'statusHorimetro': statusHorimetro,
    };

    final success = await postServices.postBDOHorimetro(novoHorimetro);
    if (success) {
      _horimetroFinalController.clear();
    }
  }

  void _salvarAlteracoes() async {
    if (_isConcluido) return;
    final success = await updateServices
        .updateBDO({'producao_id': widget.registro['producao_id']});
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => DetailsregisterPage(registros: [widget.registro])),
      );
    }
  }

  String formatDateTime(DateTime date) {
    return _dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.registro.entries.map((entry) {
                    final keyMap = {
                      'usuarioId': 'Matricula',
                      'operador': 'Operador',
                      'ciclo': 'Ciclo',
                      'cultura': 'Cultura',
                      'safra': 'Safra',
                      'talhao': 'Talhão',
                      'unidade': 'Unidade',
                      'Status': 'Status',
                      'created_at': 'Criado Em',
                      'area': 'Área',
                      'areaTrabalhada': 'Área Trabalhada',
                      'jornadaInicial': 'Jornada Inicial',
                      'jornadaFinal': 'Jornada Final',
                      'producao_id': 'Código Operação',
                      'motivo': 'Motivo',
                      'servico': 'Serviço',
                      'bem': 'Bem',
                      'hora_inicial': 'Hora Inicial',
                      'hora_final': 'Hora Final',
                      'durationstop': 'Duração Parada',
                      'horimetro_inicial': 'Horímetro Inicial',
                      'horimetro_fim': 'Horímetro Final',
                    };
                    return _buildDetailRow(
                        keyMap[entry.key] ?? entry.key, entry.value);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Edição de Motivos / Horímetro',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _novoMotivoController,
                      decoration: InputDecoration(
                        labelText: 'Motivo de Parada',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_isHorimetroFinalPreenchido) ...[
                      TextField(
                        controller: _horimetroFinalController,
                        decoration: InputDecoration(
                          labelText: 'Horímetro Final',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addNovoMotivo,
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Motivo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addHorimetroFinal,
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Horímetro'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            _motivosParada.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _motivosParada.length,
                    itemBuilder: (context, index) {
                      final motivo = _motivosParada[index];
                      final descricaoMotivo =
                          motivo['descricao'] ?? 'Motivo Desconhecido';
                      final horaInicial = motivo['hora_inicial'];
                      final horaFinal = motivo['hora_final'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                descricaoMotivo,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Hora Inicial: ${horaInicial != null ? formatDateTime(DateTime.parse(horaInicial)) : 'Data desconhecida'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                'Hora Final: ${horaFinal != null ? formatDateTime(DateTime.parse(horaFinal)) : 'Data desconhecida'}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text('Nenhum motivo adicionado')),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _salvarAlteracoes,
      //   backgroundColor: Colors.green[800],
      //   child: const Icon(Icons.save, color: Colors.white),
      // ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
              child: Text(value?.toString() ?? 'Não informado',
                  style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
