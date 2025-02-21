import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:senior/data/core/interface/app_interface.dart';
import 'package:senior/data/core/repository/api_services.dart';
import 'package:senior/data/features/dbo/pages/RegisterActivity_Page.dart';
import 'package:senior/data/views/dbo/pages/DetailsRegister_page.dart';
import 'package:senior/data/global_data.dart';

class RegisterPublicDBO extends StatefulWidget {
  @override
  _RegisterPublicDBOState createState() => _RegisterPublicDBOState();
}

class _RegisterPublicDBOState extends State<RegisterPublicDBO> {
  final GetServices getServices = GetServices();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController safraController = TextEditingController();
  final TextEditingController fazendaController = TextEditingController();
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

  List<Ciclo> getCiclo = [];
  List<Safra> getSafra = [];

  @override
  void initState() {
    super.initState();
    fetchSafra();
    fetchCiclo();
  }

  void fetchSafra() async {
    try {
      final result = await getServices.getSafra();
      setState(() {
        getSafra = result
            .map((data) =>
                Safra(Codigo: data['Codigo'], Descricao: data['Descricao']))
            .toList();
      });
    } catch (error) {
      print('Error ao buscar safras: $error');
    }
  }

  void fetchCiclo() async {
    try {
      final result = await getServices.getCiclo();
      setState(() {
        getCiclo = result
            .map((data) => Ciclo(
                Codigo: data['Codigo'],
                Descricao: data['Descricao'],
                Safra: data['Safra']))
            .toList();
      });
    } catch (error) {
      print('Error ao buscar ciclos: $error');
    }
  }

  void fetchSafraByCiclo(int safraId) async {
    try {
      var filteredSafra =
          getCiclo.where((ciclo) => ciclo.Codigo == safraId).toList();
      setState(() {
        getCiclo = filteredSafra;
      });
      print('object $filteredSafra');
    } catch (error) {
      print('Error ao buscar safras para o ciclo $safraId: $error');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                    "Operador*", _matriculaController, "Digite o operador"),
                _buildCicloDropdown(),
                _buildTextField("Safra*", safraController, "Selecione a safra"),
                _buildTextField("Fazenda*", fazendaController, "Fazenda"),
                _buildTextField("Cultura*", fazendaController, "Cultura"),
                _buildTextField("Talhão*", fazendaController, "Talhão"),
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
                const Text("Jornada de trabalho",
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Inicial", style: TextStyle(fontSize: 14)),
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
                          const Text("Final", style: TextStyle(fontSize: 14)),
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

  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      {bool isNumeric = false, Function(dynamic value)? onChanged}) {
    // Alterado para opcional
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
        onChanged: onChanged, // onChanged é agora opcional
      ),
    );
  }

  Widget _buildCicloDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: "Ciclo*",
          hintText: "Selecione o ciclo",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (value) {
          if (value != null) {
            fetchSafraByCiclo(value); // Filtra as safras com base no cicloId
          }
        },
        items: getCiclo.map((Ciclo ciclo) {
          return DropdownMenuItem<int>(
            value: ciclo.Codigo,
            child: Text(ciclo.Descricao),
          );
        }).toList(),
        validator: (value) => value == null ? "Campo obrigatório" : null,
      ),
    );
  }
}
