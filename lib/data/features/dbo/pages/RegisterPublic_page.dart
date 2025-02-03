import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisterPublicDBO extends StatefulWidget {
  const RegisterPublicDBO({Key? key}) : super(key: key);

  @override
  _RegisterPublicDBOState createState() => _RegisterPublicDBOState();
}

class _RegisterPublicDBOState extends State<RegisterPublicDBO> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _coordenadorController = TextEditingController();
  final TextEditingController _patrimonioController = TextEditingController();
  final TextEditingController _horimetroInicialController =
      TextEditingController();
  final TextEditingController _horimetroFinalController =
      TextEditingController();

  // Guardaremos data e hora iniciais/finais em duas variáveis diferentes
  DateTime? _dataHoraInicial;
  DateTime? _dataHoraFinal;

  // Lista para exibir os últimos 3 registros
  List<Map<String, dynamic>> listaLimite = [];

  // =======================
  // Seletor Data/Hora Inicial
  // =======================
  void _selecionarDataHoraInicial() {
    DateTime tempPicked = _dataHoraInicial ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              const Text(
                "Selecione Data e Hora (Início)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: tempPicked,
                  onDateTimeChanged: (DateTime dateTime) {
                    tempPicked = dateTime;
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _dataHoraInicial = tempPicked;
                  });
                  Navigator.of(context).pop(); // Fecha o bottom sheet
                },
                child: const Text("OK", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  // =======================
  // Seletor Data/Hora Final
  // =======================
  void _selecionarDataHoraFinal() {
    DateTime tempPicked = _dataHoraFinal ?? DateTime.now();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: [
              const Text(
                "Selecione Data e Hora (Final)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime: tempPicked,
                  onDateTimeChanged: (DateTime dateTime) {
                    tempPicked = dateTime;
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _dataHoraFinal = tempPicked;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("OK", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  // =======================
  // Botão Avançar
  // =======================
  void _avancar() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        listaLimite.add({
          'matricula': _matriculaController.text,
          'nomeCoordenador': _coordenadorController.text,
          'patrimonio': _patrimonioController.text,
          'dataHoraInicial': _dataHoraInicial != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(_dataHoraInicial!)
              : 'Não informada',
          'dataHoraFinal': _dataHoraFinal != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(_dataHoraFinal!)
              : 'Não informada',
          'horimetroInicial': _horimetroInicialController.text,
          'horimetroFinal': _horimetroFinalController.text,
        });
      });

      // Navegando para a tela LastRegister
      Navigator.pushNamed(context, '/lastregister');
    }
  }

  // =======================
  // Botão para Voltar (ex: para Home)
  // =======================
  void _voltarHome() {
    // Se quiser substituir a rota atual, pode usar:
    // Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    Navigator.pushNamed(context, '/home');
  }

  // =======================
  // BUILD
  // =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Atividades"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _voltarHome,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Matrícula
                const Text("Matrícula*"),
                TextFormField(
                  controller: _matriculaController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(hintText: "Digite a Matrícula"),
                  validator: (value) =>
                      value!.isEmpty ? "Matrícula é obrigatória." : null,
                ),
                const SizedBox(height: 10),

                // Nome do Coordenador
                const Text("Nome do Coordenador*"),
                TextFormField(
                  controller: _coordenadorController,
                  decoration: const InputDecoration(hintText: "Coordenador"),
                  validator: (value) => value!.isEmpty
                      ? "Nome do Coordenador é obrigatório."
                      : null,
                ),
                const SizedBox(height: 10),

                // Patrimônio
                const Text("Patrimônio*"),
                TextFormField(
                  controller: _patrimonioController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(hintText: "Digite o Patrimônio"),
                  validator: (value) =>
                      value!.isEmpty ? "Patrimônio é obrigatório." : null,
                ),
                const SizedBox(height: 10),

                // Data/Hora Inicial
                const Text("Data/Hora Inicial*"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _dataHoraInicial == null
                            ? "Não informada"
                            : DateFormat('dd/MM/yyyy HH:mm')
                                .format(_dataHoraInicial!),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _selecionarDataHoraInicial,
                      child: const Text("Selecionar"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Data/Hora Final
                const Text("Data/Hora Final*"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _dataHoraFinal == null
                            ? "Não informada"
                            : DateFormat('dd/MM/yyyy HH:mm')
                                .format(_dataHoraFinal!),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _selecionarDataHoraFinal,
                      child: const Text("Selecionar"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Horímetro
                const Text("Horímetro (opcional)"),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _horimetroInicialController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Horímetro Inicial",
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _horimetroFinalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Horímetro Final",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Botão Avançar
                Center(
                  child: ElevatedButton(
                    onPressed: _avancar,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 40,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text("Avançar"),
                  ),
                ),
                const SizedBox(height: 20),

                // Últimos 3 Registros
                const Text(
                  "Últimos 3 Registros",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                listaLimite.isNotEmpty
                    ? SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount:
                              listaLimite.length > 3 ? 3 : listaLimite.length,
                          itemBuilder: (context, index) {
                            final item = listaLimite[index];
                            return Card(
                              child: ListTile(
                                title: Text("Registro #${index + 1}"),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Matrícula: ${item['matricula']}"),
                                    Text(
                                      "Coordenador: ${item['nomeCoordenador']}",
                                    ),
                                    Text("Patrimônio: ${item['patrimonio']}"),
                                    Text(
                                      "Data/Hora Inicial: ${item['dataHoraInicial']}",
                                    ),
                                    Text(
                                      "Data/Hora Final: ${item['dataHoraFinal']}",
                                    ),
                                    Text(
                                      "Horímetro Inicial: ${item['horimetroInicial']}",
                                    ),
                                    Text(
                                      "Horímetro Final: ${item['horimetroFinal']}",
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const Text("Nenhum registro encontrado."),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
