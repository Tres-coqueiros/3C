import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:senior/data/app_database.dart';
import 'package:senior/data/features/dbo/pages/RegisterActivity_Page.dart';
import 'package:senior/data/features/dbo/pages/DetailsRegister_page.dart';

class RegisterPublicDBO extends StatefulWidget {
  const RegisterPublicDBO({super.key});

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

  /// **Salva no banco e navega para a próxima tela**
  Future<void> _salvarRegistro() async {
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
      final database = Provider.of<AppDatabase>(context, listen: false);

      // Inserindo no banco
      final id = await database.inserirAtividade(
        AtividadesCompanion(
          descricao: drift.Value(_matriculaController.text),
          coordenador: drift.Value(_coordenadorController.text),
          patrimonio: drift.Value(_patrimonioController.text),
          horarioInicial: drift.Value(_horarioInicial!),
          horarioFinal: drift.Value(_horarioFinal!),
          horimetroInicial: drift.Value(_horimetroInicialController.text),
          horimetroFinal: drift.Value(_horimetroFinalController.text),
        ),
      );

      // Busca o registro recém-criado no banco
      final registro = await database.obterAtividadePorId(id);

      // Navega para a próxima tela com os dados do banco
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterActivityPage(
            atividade: registro != null ? registro.toJson() : {},
            dados: [],
            informacoesGerais: {},
          ),
        ),
      );
    }
  }

  /// **Mostra os registros salvos**
  void _mostrarRegistros() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsregisterPage(
          registros: [],
        ),
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
            onPressed: _mostrarRegistros,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _salvarRegistro,
          child: const Text('Salvar e Avançar'),
        ),
      ),
    );
  }
}
