import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/global_data.dart';
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
  final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  late List<dynamic> _motivosParada;
  late bool _isConcluido;

  @override
  void initState() {
    super.initState();
    if (widget.registro.containsKey('motivosParada') &&
        widget.registro['motivosParada'] is List) {
      _motivosParada = List.from(widget.registro['motivosParada']);
    } else {
      _motivosParada = [];
    }

    _isConcluido = (widget.registro['Status'] == 'concluido');

    final horimetroFinalStr =
        widget.registro['horimetroFinal']?.toString() ?? '';
    _horimetroFinalController.text = horimetroFinalStr;
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value != null ? value.toString() : 'Não informado',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDateTime() async {
    DateTime? selecionado;
    await DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onConfirm: (date) {
        selecionado = date;
      },
      currentTime: DateTime.now(),
      locale: LocaleType.pt,
    );
    return selecionado;
  }

  Future<void> _addNovoMotivo() async {
    if (_isConcluido) return;

    final horimetroFinalStr = _horimetroFinalController.text.trim();
    final double? horimetroFinal = double.tryParse(horimetroFinalStr);

    final horimetroInicialStr = widget.registro['horimetroInicial']?.toString();
    final double? horimetroInicial = horimetroInicialStr != null
        ? double.tryParse(horimetroInicialStr)
        : null;

    final descricao = _novoMotivoController.text.trim();
    if (descricao.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite o motivo antes de adicionar!")),
      );
      return;
    }

    final inicio = await _pickDateTime();
    if (inicio == null) return;

    final fim = await _pickDateTime();
    if (fim == null) return;

    if (fim.isBefore(inicio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hora final não pode ser antes da inicial!"),
        ),
      );
      return;
    }

    if (horimetroFinal != null && horimetroInicial != null) {
      if (horimetroFinal <= horimetroInicial) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horímetro Final deve ser maior que o Inicial!'),
          ),
        );
        return;
      }
      if ((horimetroFinal - horimetroInicial) > 12) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horímetro excede as 12 horas de trabalho!'),
          ),
        );
        return;
      }
    }

    final duracaoMin = fim.difference(inicio).inMinutes;
    final novoMotivo = {
      'producao_id': widget.registro['producao_id'],
      'servico': widget.registro['servico'],
      'bem': widget.registro['bem'],
      'horimentroInicial': widget.registro['horimentro_inicial'],
      'descricao': descricao,
      'inicio': _dateTimeFormat.format(inicio),
      'fim': _dateTimeFormat.format(fim),
      'duracaoMin': duracaoMin,
      'horimetroFinal': _horimetroFinalController.text,
    };

    final success = await postServices.postBDOMotivo(novoMotivo);
    if (success) {
      setState(() {
        _motivosParada.add(novoMotivo);
        _novoMotivoController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Motivo adicionado com sucesso!")),
      );
    }
  }

  void _salvarAlteracoes() async {
    if (_isConcluido) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      widget.registro['motivosParada'] = _motivosParada;
      widget.registro['horimetroFinal'] = _horimetroFinalController.text;
    });
    final data = {'producao_id': widget.registro['producao_id']};

    try {
      bool success = await updateServices.updateBDO(data);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Alterações salvas com sucesso!")),
        );

        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsregisterPage(registros: [widget.registro]),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Falha ao salvar as alterações.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar alterações: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.registro.isEmpty) {
      return Scaffold(
        body: const Center(
          child: Text(
            'Nenhum registro selecionado.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final bool hasHorimetroFinal = (widget.registro['horimetroFinal'] != null &&
        widget.registro['horimetroFinal'].toString().isNotEmpty);

    return Scaffold(
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ...widget.registro.entries.map((entry) {
                        final k = entry.key;
                        final v = entry.value;

                        if (k == 'motivosParada' || k == 'horimetroFinal') {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(k, v),
                            const Divider(height: 8),
                          ],
                        );
                      }).toList(),
                      if (_isConcluido || hasHorimetroFinal) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'horimetroFinal',
                          widget.registro['horimetroFinal']?.toString() ??
                              'Não informado',
                        ),
                      ],
                      if (_isConcluido) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Registro Concluído',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Edição de motivos de parada não é permitida.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (!_isConcluido) ...[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // TÍTULO
                        const Text(
                          'Edição de Motivos / Horímetro',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _novoMotivoController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Motivo de Parada',
                            hintText: 'Ex: Chuva forte',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        if (!hasHorimetroFinal) ...[
                          TextField(
                            controller: _horimetroFinalController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Horímetro Final',
                              hintText: 'Digite o Horímetro Final',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: _addNovoMotivo,
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _motivosParada.isEmpty
                      ? const Text('Nenhum motivo de parada cadastrado.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _motivosParada.length,
                          itemBuilder: (context, index) {
                            final m = _motivosParada[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                              child: ListTile(
                                title: Text(m['descricao'] ?? 'Sem descrição'),
                                subtitle: Text(
                                  'Início: ${m['inicio']}\n'
                                  'Fim: ${m['fim']}\n'
                                  'Duração: ${m['duracaoMin']} min',
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _salvarAlteracoes,
        backgroundColor: Colors.green[800],
        child: const Icon(Icons.save, color: Colors.white),
      ),
    );
  }
}
