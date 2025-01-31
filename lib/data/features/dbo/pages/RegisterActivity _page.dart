import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisteractivityPage extends StatefulWidget {
  final List<dynamic> dados;
  final Map<String, dynamic> informacoesGerais;

  const RegisteractivityPage({
    super.key,
    required this.dados,
    required this.informacoesGerais,
  });

  @override
  State<RegisteractivityPage> createState() => _RegisteractivityPageState();
}

class _RegisteractivityPageState extends State<RegisteractivityPage> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _timeFormat = DateFormat('HH:mm');

  late List<dynamic> _dados;
  final Map<String, dynamic> _informacoesGerais = {};

  // Controladores para os campos de texto
  final TextEditingController _patrimonioController = TextEditingController();
  final TextEditingController _operacaoController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _talhaoController = TextEditingController();
  final TextEditingController _culturaController = TextEditingController();

  DateTime? _horaInicial;
  DateTime? _horaFinal;
  bool _horaRangeError = false;

  @override
  void initState() {
    super.initState();
    _dados = widget.dados;
    _informacoesGerais.addAll(widget.informacoesGerais);
  }

  Future<void> _selectTime(BuildContext context, bool isInitial) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      setState(() {
        if (isInitial) {
          _horaInicial = selectedDateTime;
        } else {
          _horaFinal = selectedDateTime;
        }
      });
    }
  }

  void _handleAdicionar() {
    setState(() {
      _horaRangeError = _horaFinal != null &&
          _horaInicial != null &&
          _horaFinal!.isBefore(_horaInicial!);
    });

    if (_formKey.currentState!.validate() && !_horaRangeError) {
      final combinedData = {
        ..._informacoesGerais,
        'patrimonioImplemento': _patrimonioController.text,
        'operacao': _operacaoController.text,
        'motivo': _motivoController.text,
        'talhao': _talhaoController.text,
        'cultura': _culturaController.text,
        'horaInicial': _horaInicial,
        'horaFinal': _horaFinal,
      };

      setState(() {
        _dados.add(combinedData);
      });

      // Navegação de volta
      Navigator.pop(context, _dados);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOptionalField(
                    'Patrimônio Implemento (opcional)', _patrimonioController),
                _buildRequiredField('Operação*', _operacaoController),
                _buildRequiredField('Motivo de Parada*', _motivoController),
                _buildRequiredField('Talhão*', _talhaoController),
                _buildOptionalField('Cultura (opcional)', _culturaController),
                const SizedBox(height: 16),
                const Text('Horários*', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Inicial*'),
                          InkWell(
                            onTap: () => _selectTime(context, true),
                            child: InputDecorator(
                              decoration: const InputDecoration(),
                              child: Text(
                                _horaInicial != null
                                    ? _timeFormat.format(_horaInicial!)
                                    : 'Selecione',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Final*'),
                          InkWell(
                            onTap: () => _selectTime(context, false),
                            child: InputDecorator(
                              decoration: const InputDecoration(),
                              child: Text(
                                _horaFinal != null
                                    ? _timeFormat.format(_horaFinal!)
                                    : 'Selecione',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_horaRangeError)
                  const Text(
                    'Horário Final não pode ser antes do Horário Inicial.',
                    style: TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleAdicionar,
                  child: const Text('Adicionar'),
                ),
                const SizedBox(height: 24),
                const Text('Últimos 3 Registros',
                    style: TextStyle(fontSize: 18)),
                _buildLastRecords(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequiredField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextFormField(
          controller: controller,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Campo obrigatório' : null,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOptionalField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLastRecords() {
    final lastRecords =
        _dados.length > 3 ? _dados.sublist(_dados.length - 3) : _dados;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: lastRecords.length,
      itemBuilder: (context, index) {
        final item = lastRecords.reversed.toList()[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Registro #${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                _buildDataRow('Patrimônio Implemento:',
                    item['patrimonioImplemento'] ?? 'Não informado'),
                _buildDataRow('Operação:', item['operacao'] ?? 'Não informado'),
                _buildDataRow('Motivo:', item['motivo'] ?? 'Não informado'),
                _buildDataRow('Talhão:', item['talhao'] ?? 'Não informado'),
                _buildDataRow(
                    'Horário Inicial:',
                    item['horaInicial'] != null
                        ? _timeFormat.format(item['horaInicial'])
                        : 'Não informado'),
                _buildDataRow(
                    'Horário Final:',
                    item['horaFinal'] != null
                        ? _timeFormat.format(item['horaFinal'])
                        : 'Não informado'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}
