import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:senior/data/global_data.dart';

class RegisterActivityPage extends StatefulWidget {
  final List<dynamic> dados;
  final Map<String, dynamic> informacoesGerais;

  const RegisterActivityPage({
    Key? key,
    required this.dados,
    required this.informacoesGerais,
    required Map<String, Object?> atividade,
  }) : super(key: key);

  @override
  State<RegisterActivityPage> createState() => _RegisterActivityPageState();
}

class _RegisterActivityPageState extends State<RegisterActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  late List<dynamic> _dados;
  late Map<String, dynamic> _informacoesGerais;

  final TextEditingController _patrimonioImplementoController =
      TextEditingController();
  final TextEditingController _operacaoController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _talhaoController = TextEditingController();
  final TextEditingController _culturaController = TextEditingController();
  final TextEditingController _horimetroInicialController =
      TextEditingController();
  final TextEditingController _horimetroFinalController =
      TextEditingController();

  String? _horarioInicial;
  String? _horarioFinal;
  bool _horaRangeError = false;
  bool _horimetroError = false;

  @override
  void initState() {
    super.initState();
    _dados = widget.dados;
    _informacoesGerais = widget.informacoesGerais;

    _patrimonioImplementoController.text =
        _informacoesGerais['patrimonioImplemento'] ?? '';
    _horarioInicial = _informacoesGerais['horarioInicial'];
    _horarioFinal = _informacoesGerais['horarioFinal'];
  }

  /// **Seleciona data e hora**
  void _selecionarHorario(BuildContext context, bool isInicial) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onConfirm: (date) {
        setState(() {
          String formatted = _dateTimeFormat.format(date);
          if (isInicial) {
            _horarioInicial = formatted;
          } else {
            _horarioFinal = formatted;
          }
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.pt,
    );
  }

  /// **Valida e adiciona os dados ao histórico sem duplicação**
  void _handleAdicionar() {
    double? horimetroInicial =
        double.tryParse(_horimetroInicialController.text);
    double? horimetroFinal = double.tryParse(_horimetroFinalController.text);

    setState(() {
      _horaRangeError = _horarioInicial != null &&
          _horarioFinal != null &&
          _dateTimeFormat
              .parse(_horarioFinal!)
              .isBefore(_dateTimeFormat.parse(_horarioInicial!));

      _horimetroError = horimetroInicial != null &&
          horimetroFinal != null &&
          horimetroFinal <= horimetroInicial;
    });

    if (_formKey.currentState!.validate() &&
        !_horaRangeError &&
        !_horimetroError) {
      final combinedData = {
        ..._informacoesGerais,
        'patrimonioImplemento': _patrimonioImplementoController.text.isNotEmpty
            ? _patrimonioImplementoController.text
            : 'Não informado',
        'operacao': _operacaoController.text,
        'motivo': _motivoController.text,
        'talhao': _talhaoController.text,
        'cultura': _culturaController.text,
        'horaInicial': _horarioInicial ?? 'Não informado',
        'horaFinal': _horarioFinal ?? 'Não informado',
        'horimetroInicial': _horimetroInicialController.text,
        'horimetroFinal': _horimetroFinalController.text,
      };

      if (!_dados.contains(combinedData)) {
        setState(() {
          _dados.add(combinedData);
          listaDeRegistros.add(combinedData);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          duration: Duration(seconds: 1),
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    }
  }

  /// **Criar campo de entrada de texto formatado**
  Widget _buildTextField(
      String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? "Campo obrigatório" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text('Cadastro de Atividades',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/detailsregister'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField("Patrimônio", _patrimonioImplementoController,
                    "Digite o Patrimônio"),
                _buildTextField("Patrimônio Implemento",
                    _patrimonioImplementoController, "Digite o Patrimônio"),
                _buildTextField("Maquina", _patrimonioImplementoController,
                    "Digite o Patrimônio"),
                _buildTextField(
                    "Operação", _operacaoController, "Digite a Operação"),
                _buildTextField(
                    "Motivo de Parada", _motivoController, "Digite o Motivo"),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField("Horímetro Inicial",
                          _horimetroInicialController, "Digite o Horímetro"),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField("Horímetro Final",
                          _horimetroFinalController, "Digite o Horímetro"),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selecionarHorario(context, true),
                        child: Text(
                          _horarioInicial ?? "Selecionar Hora Inicial",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selecionarHorario(context, false),
                        child: Text(
                          _horarioFinal ?? "Selecionar Hora Final",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                    ),
                    onPressed: _handleAdicionar,
                    child: const Text(
                      'Adicionar Atividade',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
