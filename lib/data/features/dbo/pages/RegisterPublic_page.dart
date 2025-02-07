import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:senior/data/features/dbo/pages/RegisterActivity_Page.dart';
import 'package:senior/data/features/dbo/pages/DetailsRegister_page.dart';
import 'package:senior/data/global_data.dart'; // Lista global de registros

class RegisterPublicDBO extends StatefulWidget {
  @override
  _RegisterPublicDBOState createState() => _RegisterPublicDBOState();
}

class _RegisterPublicDBOState extends State<RegisterPublicDBO> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _coordenadorController = TextEditingController();
  final TextEditingController _patrimonioController = TextEditingController();
  final TextEditingController _horimetroInicialController =
      TextEditingController();
  final TextEditingController _horimetroFinalController =
      TextEditingController();

  String? _horarioInicial;
  String? _horarioFinal;
  bool _horarioError = false;
  bool _horimetroError = false;

  /// **Seleciona a data/hora**
  void _selecionarHorario(BuildContext context, bool isInicial) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      onConfirm: (date) {
        setState(() {
          String formatted = DateFormat('dd/MM/yyyy HH:mm').format(date);
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

  /// **Salva o registro e avança para a próxima tela**
  void _salvarRegistro() {
    setState(() {
      _horarioError = _horarioInicial == null || _horarioFinal == null;
      _horimetroError =
          double.tryParse(_horimetroInicialController.text) == null ||
              double.tryParse(_horimetroFinalController.text) == null ||
              double.parse(_horimetroFinalController.text) <=
                  double.parse(_horimetroInicialController.text);
    });

    if (_formKey.currentState!.validate() &&
        !_horarioError &&
        !_horimetroError) {
      final registro = {
        'matricula': _matriculaController.text,
        'nomeCoordenador': _coordenadorController.text,
        'patrimonio': _patrimonioController.text,
        'horarioInicial': _horarioInicial,
        'horarioFinal': _horarioFinal,
        'horimetroInicial': _horimetroInicialController.text,
        'horimetroFinal': _horimetroFinalController.text,
        'operacoes': [] // Lista de operações vazia para receber novas operações
      };

      listaDeRegistros.add(registro);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterActivityPage(
            dados: listaDeRegistros,
            informacoesGerais: registro,
            atividade: registro,
          ),
        ),
      );
    }
  }

  /// **Navega para a tela de registros**
  void _mostrarRegistros() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DetailsregisterPage(
                registros: [],
              )),
    );
  }

  /// **Cria um campo de entrada de texto formatado**
  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
        title: const Text("Cadastro de Atividades",
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: _mostrarRegistros, // Agora leva para a tela de registros
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
                _buildTextField(
                    "Matrícula*", _matriculaController, "Digite a Matrícula"),
                _buildTextField("Nome do Coordenador*", _coordenadorController,
                    "Digite o Coordenador"),
                _buildTextField("Patrimônio*", _patrimonioController,
                    "Digite o Patrimônio"),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField("Horímetro Inicial*",
                          _horimetroInicialController, "Digite o Horímetro",
                          isNumeric: true),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField("Horímetro Final*",
                          _horimetroFinalController, "Digite o Horímetro",
                          isNumeric: true),
                    ),
                  ],
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
                const Text("Data e Horários*", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Inicial*",
                              style: TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: () => _selecionarHorario(context, true),
                            child: Text(_horarioInicial ?? "Selecione",
                                style: const TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Final*", style: TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          ElevatedButton(
                            onPressed: () => _selecionarHorario(context, false),
                            child: Text(_horarioFinal ?? "Selecione",
                                style: const TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_horarioError)
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                    ),
                    onPressed: _salvarRegistro,
                    child: const Text(
                      'Salvar e Avançar',
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
