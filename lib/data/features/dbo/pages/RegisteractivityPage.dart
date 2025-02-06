import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RegisteractivityPage extends StatefulWidget {
  final List<dynamic> dados;
  final Map<String, dynamic> informacoesGerais;

  const RegisteractivityPage({
    super.key,
    this.dados = const [],
    this.informacoesGerais = const {},
  });

  @override
  State<RegisteractivityPage> createState() => _RegisteractivityPageState();
}

class _RegisteractivityPageState extends State<RegisteractivityPage> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

  late List<dynamic> _dados;
  late Map<String, dynamic> _informacoesGerais;

  final _patrimonioController = TextEditingController();
  final _operacaoController = TextEditingController();
  final _motivoController = TextEditingController();
  final _talhaoController = TextEditingController();
  final _culturaController = TextEditingController();

  DateTime? _horaInicial;
  DateTime? _horaFinal;
  bool _horaRangeError = false;

  @override
  void initState() {
    super.initState();
    _dados = List.from(widget.dados);
    _informacoesGerais = Map.from(widget.informacoesGerais);
  }

  /// **Selecionar Hora**
  Future<void> _selectTime(bool isInitial) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        final selectedDateTime =
            DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

        if (isInitial) {
          _horaInicial = selectedDateTime;
        } else {
          _horaFinal = selectedDateTime;
        }
      });
    }
  }

  /// **Adicionar Registro**
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
        'horaInicial': _horaInicial != null
            ? _dateTimeFormat.format(_horaInicial!)
            : "Não informado",
        'horaFinal': _horaFinal != null
            ? _dateTimeFormat.format(_horaFinal!)
            : "Não informado",
      };

      setState(() => _dados.add(combinedData));

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Resumo do Registro"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: combinedData.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "${e.key}: ${e.value}",
                  style: const TextStyle(fontSize: 16),
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              child: const Text("OK", style: TextStyle(fontSize: 16)),
              onPressed: () {
                Navigator.pop(context);
                context.go('/dboHome', extra: {'dados': List.from(_dados)});
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastrar Atividade")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField("Patrimônio Implemento", _patrimonioController),
                _buildTextField("Operação", _operacaoController),
                _buildTextField("Motivo", _motivoController),
                _buildTextField("Talhão", _talhaoController),
                _buildTextField("Cultura", _culturaController),
                _buildTimePicker(
                    "Hora Inicial", _horaInicial, () => _selectTime(true)),
                _buildTimePicker(
                    "Hora Final", _horaFinal, () => _selectTime(false)),
                if (_horaRangeError)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text("A hora final não pode ser antes da inicial",
                        style: TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _handleAdicionar,
                  child: const Text("Adicionar Atividade"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
      ),
    );
  }

  Widget _buildTimePicker(String label, DateTime? time, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label: ${time != null ? _dateTimeFormat.format(time) : "Não informado"}",
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(icon: const Icon(Icons.access_time), onPressed: onTap),
        ],
      ),
    );
  }
}
