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
  final List<Map<String, dynamic>> _motivosParada = [];

  late bool _isHorimetroFinalPreenchido;

  @override
  void initState() {
    super.initState();
    print(widget.registro['registros']);
    _horimetroFinalController.text =
        widget.registro['horimetroFinal']?.toString() ?? '';
    _isHorimetroFinalPreenchido = widget.registro['horimetroFinal'] != null;
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

    final registros = widget.registro['registros'];
    if (registros == null || registros.isEmpty) {
      print('Erro: Nenhum registro encontrado.');
      return;
    }

    final primeiroRegistro = registros[0];

    final novoMotivo = {
      'servico': primeiroRegistro['servico_id'],
      'descricao': descricao,
      'inicio': _dateFormat.format(inicio),
      'fim': _dateFormat.format(fim),
      'horimetroInicial': primeiroRegistro['horimetro_inicial'],
      'bem': primeiroRegistro['bem_id'],
      'producao_id': primeiroRegistro['producao_id'],
    };

    final response = await postServices.postBDOMotivo(novoMotivo);
    if (response['success']) {
      final addMotivo = response['motivo'];
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

    final registros = widget.registro['registros'];
    if (registros == null || registros.isEmpty) {
      print('Erro: Nenhum registro encontrado.');
      return;
    }
    final primeiroRegistro = registros[0];

    final novoHorimetro = {
      'horimetroFinal': _horimetroFinalController.text,
      'producao_id': primeiroRegistro['producao_id'],
      'statusHorimetro': statusHorimetro,
    };

    final success = await postServices.postBDOHorimetro(novoHorimetro);
    if (success) {
      _horimetroFinalController.clear();
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
                  children: [
                    if (widget.registro['registros'] != null &&
                        widget.registro['registros'] is List)
                      ...List<Map<String, dynamic>>.from(
                              widget.registro['registros'])
                          .map((registro) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'Registro de Deslocamento',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...registro.entries.map((entry) {
                              final keyMap = {
                                'id': 'ID',
                                'producao_id': 'Código Operação',
                                'motivo': 'Motivo',
                                'servico': 'Serviço',
                                'bem': 'Bem',
                                'hora_inicial': 'Hora Inicial',
                                'hora_final': 'Hora Final',
                                'durationstop': 'Duração Parada',
                                'horimetro_inicial': 'Horímetro Inicial',
                                'horimetro_fim': 'Horímetro Final',
                                'created_at': 'Criado Em',
                              };
                              return _buildDetailRow(
                                keyMap[entry.key] ?? entry.key,
                                entry.value?.toString() ?? "Não informado",
                              );
                            }).toList(),
                          ],
                        );
                      }).toList(),
                  ],
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
            _motivosParada.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _motivosParada.length,
                    itemBuilder: (context, index) {
                      final motivo = _motivosParada[index];
                      final descricaoMotivo =
                          motivo['motivo'] ?? 'Motivo Desconhecido';
                      final horaInicial = motivo['hora_inicial'];
                      final horaFinal = motivo['hora_final'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'Não informado',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
