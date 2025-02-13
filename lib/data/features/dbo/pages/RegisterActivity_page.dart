import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:senior/data/app_database.dart';
//import 'package:senior/data/database/app_database.dart'; // Importa o banco de dados Drift
import 'package:drift/drift.dart' as drift;
import 'package:provider/provider.dart';

class RegisterActivityPage extends StatefulWidget {
  final List<dynamic> dados;
  final Map<String, dynamic> informacoesGerais;
  final Map<String, dynamic> atividade;

  const RegisterActivityPage({
    Key? key,
    required this.dados,
    required this.informacoesGerais,
    required this.atividade,
  }) : super(key: key);

  @override
  State<RegisterActivityPage> createState() => _RegisterActivityPageState();
}

class _RegisterActivityPageState extends State<RegisterActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

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

    _patrimonioImplementoController.text =
        widget.atividade['patrimonioImplemento'] ?? '';
    _horarioInicial = widget.atividade['horarioInicial'];
    _horarioFinal = widget.atividade['horarioFinal'];
  }

  /// **Seleciona Data e Hora**
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

  /// **Armazena os dados no banco de dados Drift**
  Future<void> _handleAdicionar() async {
    final database = Provider.of<AppDatabase>(context, listen: false);

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
      final novaAtividade = AtividadesCompanion(
        descricao: drift.Value(_operacaoController.text),
        coordenador: drift.Value(widget.informacoesGerais['nomeCoordenador']),
        patrimonio: drift.Value(_patrimonioImplementoController.text),
        horarioInicial: drift.Value(_horarioInicial ?? 'Não informado'),
        horarioFinal: drift.Value(_horarioFinal ?? 'Não informado'),
        horimetroInicial: drift.Value(_horimetroInicialController.text),
        horimetroFinal: drift.Value(_horimetroFinalController.text),
      );

      await database.inserirAtividade(novaAtividade);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atividade salva com sucesso!'),
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
                _buildTextField("Patrimônio Implemento",
                    _patrimonioImplementoController, "Digite o Patrimônio"),
                _buildTextField(
                    "Operação", _operacaoController, "Digite a Operação"),
                _buildTextField(
                    "Motivo de Parada", _motivoController, "Digite o Motivo"),
                _buildTextField("Talhão", _talhaoController, "Digite o Talhão"),
                _buildTextField(
                    "Cultura", _culturaController, "Digite a Cultura"),
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selecionarHorario(context, false),
                        child: Text(
                          _horarioFinal ?? "Selecionar Hora Final",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _handleAdicionar,
                    child: const Text('Adicionar Atividade'),
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
