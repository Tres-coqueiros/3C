import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:senior/data/global_data.dart'; // Importa a variável global

class RegisterActivityPage extends StatefulWidget {
  final List<dynamic> dados;
  final Map<String, dynamic> informacoesGerais;

  const RegisterActivityPage({
    Key? key,
    required this.dados,
    required this.informacoesGerais,
  }) : super(key: key);

  @override
  State<RegisterActivityPage> createState() => _RegisterActivityPageState();
}

class _RegisterActivityPageState extends State<RegisterActivityPage> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  late List<dynamic> _dados;
  late Map<String, dynamic> _informacoesGerais;

  // Controladores para os campos de texto
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

  DateTime? _horaInicial;
  DateTime? _horaFinal;
  bool _horaRangeError = false;
  bool _horimetroError = false;

  @override
  void initState() {
    super.initState();
    _dados = widget.dados;
    _informacoesGerais = widget.informacoesGerais;
  }

  /// Seleciona data e hora usando o DatePicker
  Future<void> _selectDateTime(BuildContext context, bool isInitial) async {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onConfirm: (date) {
        setState(() {
          if (isInitial) {
            _horaInicial = date;
          } else {
            _horaFinal = date;
          }
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.pt,
    );
  }

  void _handleAdicionar() {
    // Validação do horímetro
    double? horimetroInicial =
        double.tryParse(_horimetroInicialController.text);
    double? horimetroFinal = double.tryParse(_horimetroFinalController.text);

    setState(() {
      _horaRangeError = _horaInicial != null &&
          _horaFinal != null &&
          _horaFinal!.isBefore(_horaInicial!);
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
        'horaInicial': _horaInicial != null
            ? _dateTimeFormat.format(_horaInicial!)
            : 'Não informado',
        'horaFinal': _horaFinal != null
            ? _dateTimeFormat.format(_horaFinal!)
            : 'Não informado',
        'horimetroInicial': _horimetroInicialController.text,
        'horimetroFinal': _horimetroFinalController.text,
      };

      setState(() {
        _dados.add(combinedData);
        listaDeRegistros.add(combinedData); // Atualiza a variável global
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cadastro realizado com sucesso!',
            style: TextStyle(fontSize: 16),
          ),
          duration: Duration(seconds: 1),
        ),
      );

      Future.delayed(const Duration(seconds: 1), () {
        // Volta para a tela de cadastro inicial
        Navigator.pushReplacementNamed(context, '/registerpublic');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Atividades'),
        actions: [
          // Ícone para acessar o histórico de registros
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico de Registros',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/detailsregister',
                arguments: listaDeRegistros,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Patrimônio Implemento (opcional)',
                  style: TextStyle(fontSize: 16),
                ),
                TextFormField(
                  controller: _patrimonioImplementoController,
                  decoration: const InputDecoration(
                    hintText: 'Digite o Patrimônio Implemento',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Operação*',
                  style: TextStyle(fontSize: 16),
                ),
                TextFormField(
                  controller: _operacaoController,
                  decoration: const InputDecoration(
                    hintText: 'Digite a Operação',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Motivo de Parada*',
                  style: TextStyle(fontSize: 16),
                ),
                TextFormField(
                  controller: _motivoController,
                  decoration: const InputDecoration(
                    hintText: 'Digite o Motivo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Talhão*',
                  style: TextStyle(fontSize: 16),
                ),
                TextFormField(
                  controller: _talhaoController,
                  decoration: const InputDecoration(
                    hintText: 'Digite o Talhão',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cultura (opcional)',
                  style: TextStyle(fontSize: 16),
                ),
                TextFormField(
                  controller: _culturaController,
                  decoration: const InputDecoration(
                    hintText: 'Digite a Cultura',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Horímetro Inicial*',
                  style: TextStyle(fontSize: 16),
                ),
                TextFormField(
                  controller: _horimetroInicialController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Digite o Horímetro Inicial',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Campo obrigatório'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Horímetro Final*',
                  style: TextStyle(fontSize: 16),
                ),
                TextFormField(
                  controller: _horimetroFinalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Digite o Horímetro Final',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Campo obrigatório'
                      : null,
                ),
                if (_horimetroError)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '⚠️ Horímetro Final deve ser maior que o Inicial!',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Data e Horários*',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Inicial*'),
                          ElevatedButton(
                            onPressed: () => _selectDateTime(context, true),
                            child: Text(
                              _horaInicial != null
                                  ? _dateTimeFormat.format(_horaInicial!)
                                  : 'Selecione',
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
                          ElevatedButton(
                            onPressed: () => _selectDateTime(context, false),
                            child: Text(
                              _horaFinal != null
                                  ? _dateTimeFormat.format(_horaFinal!)
                                  : 'Selecione',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_horaRangeError)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '⚠️ Data/Horário Final deve ser maior que o Inicial!',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _handleAdicionar,
                    child: const Text(
                      'Adicionar',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
