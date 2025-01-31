import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

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
  List<Map<String, dynamic>> listaLimite = [];

  void _selecionarHorario(BuildContext context, bool isInicial) {
    // DatePicker.showTimePicker(
    //   context,
    //   showSecondsColumn: false,
    //   onConfirm: (time) {
    //     setState(() {
    //       if (isInicial) {
    //         _horarioInicial = "${time.hour}:${time.minute}";
    //       } else {
    //         _horarioFinal = "${time.hour}:${time.minute}";
    //       }
    //     });
    //   },
    // );
  }

  void _avancar() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        listaLimite.add({
          'matricula': _matriculaController.text,
          'nomeCoordenador': _coordenadorController.text,
          'patrimonio': _patrimonioController.text,
          'horarioInicial': _horarioInicial ?? 'Não informado',
          'horarioFinal': _horarioFinal ?? 'Não informado',
          'horimetroInicial': _horimetroInicialController.text,
          'horimetroFinal': _horimetroFinalController.text,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cadastro de Atividades")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Matrícula*"),
                TextFormField(
                  controller: _matriculaController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "Digite a Matrícula"),
                  validator: (value) =>
                      value!.isEmpty ? "Matrícula é obrigatória." : null,
                ),
                SizedBox(height: 10),
                Text("Nome do Coordenador*"),
                TextFormField(
                  controller: _coordenadorController,
                  decoration: InputDecoration(hintText: "Coordenador"),
                  validator: (value) => value!.isEmpty
                      ? "Nome do Coordenador é obrigatório."
                      : null,
                ),
                SizedBox(height: 10),
                Text("Patrimônio*"),
                TextFormField(
                  controller: _patrimonioController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: "Digite o Patrimônio"),
                  validator: (value) =>
                      value!.isEmpty ? "Patrimônio é obrigatório." : null,
                ),
                SizedBox(height: 10),
                Text("Horários*"),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text("Inicial*"),
                          ElevatedButton(
                            onPressed: () => _selecionarHorario(context, true),
                            child: Text(_horarioInicial ?? "Selecione"),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text("Final*"),
                          ElevatedButton(
                            onPressed: () => _selecionarHorario(context, false),
                            child: Text(_horarioFinal ?? "Selecione"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text("Horímetro"),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _horimetroInicialController,
                        keyboardType: TextInputType.number,
                        decoration:
                            InputDecoration(hintText: "Horímetro Inicial"),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _horimetroFinalController,
                        keyboardType: TextInputType.number,
                        decoration:
                            InputDecoration(hintText: "Horímetro Final"),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _avancar,
                  child: Text("Avançar"),
                ),
                SizedBox(height: 20),
                Text("Últimos 3 Registros",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                listaLimite.isNotEmpty
                    ? Container(
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
                                        "Coordenador: ${item['nomeCoordenador']}"),
                                    Text("Patrimônio: ${item['patrimonio']}"),
                                    Text(
                                        "Horário Inicial: ${item['horarioInicial']}"),
                                    Text(
                                        "Horário Final: ${item['horarioFinal']}"),
                                    Text(
                                        "Horímetro Inicial: ${item['horimetroInicial']}"),
                                    Text(
                                        "Horímetro Final: ${item['horimetroFinal']}"),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Text("Nenhum registro encontrado."),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
