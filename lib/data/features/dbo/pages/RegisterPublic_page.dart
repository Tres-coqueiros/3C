import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:senior/data/features/dbo/pages/RegisterActivity_page.dart';
import 'package:senior/data/global_data.dart'; // Variável global listaDeRegistros

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

  /// **Selecionar Data e Hora com Formatação Correta**
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

  /// **Avançar para a Próxima Tela**
  void _avancar() {
    setState(() {
      _horarioError = false;
      _horimetroError = false;
    });

    if (_formKey.currentState!.validate()) {
      if (_horarioInicial == null || _horarioFinal == null) {
        setState(() {
          _horarioError = true;
        });
        return;
      }
      try {
        final dtInicial =
            DateFormat('dd/MM/yyyy HH:mm').parse(_horarioInicial!);
        final dtFinal = DateFormat('dd/MM/yyyy HH:mm').parse(_horarioFinal!);
        if (dtFinal.isBefore(dtInicial)) {
          setState(() {
            _horarioError = true;
          });
          return;
        }
      } catch (e) {
        setState(() {
          _horarioError = true;
        });
        return;
      }

      double? horimetroInicial =
          double.tryParse(_horimetroInicialController.text);
      double? horimetroFinal = double.tryParse(_horimetroFinalController.text);
      if (horimetroInicial == null ||
          horimetroFinal == null ||
          horimetroFinal <= horimetroInicial) {
        setState(() {
          _horimetroError = true;
        });
        return;
      }

      final informacoesGerais = {
        'matricula': _matriculaController.text,
        'nomeCoordenador': _coordenadorController.text,
        'patrimonio': _patrimonioController.text,
        'horarioInicial': _horarioInicial,
        'horarioFinal': _horarioFinal,
        'horimetroInicial': _horimetroInicialController.text,
        'horimetroFinal': _horimetroFinalController.text,
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterActivityPage(
            dados: listaDeRegistros,
            informacoesGerais: informacoesGerais,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Cadastro de Atividades"),
      //   actions: [
      //     // Botão para visualizar o histórico de registros
      //     IconButton(
      //       icon: const Icon(Icons.history),
      //       tooltip: 'Histórico de Registros',
      //       onPressed: () => Navigator.pushNamed(context, '/detailsregister'),
      //     )
      //   ],
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Matrícula*"),
                TextFormField(
                  controller: _matriculaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Digite a Matrícula",
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Matrícula é obrigatória." : null,
                ),
                const SizedBox(height: 10),
                const Text("Nome do Coordenador*"),
                TextFormField(
                  controller: _coordenadorController,
                  decoration: const InputDecoration(hintText: "Coordenador"),
                  validator: (value) => value!.isEmpty
                      ? "Nome do Coordenador é obrigatório."
                      : null,
                ),
                const SizedBox(height: 10),
                const Text("Patrimônio*"),
                TextFormField(
                  controller: _patrimonioController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Digite o Patrimônio",
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Patrimônio é obrigatório." : null,
                ),
                const SizedBox(height: 10),
                const Text("Horímetro"),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _horimetroInicialController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Horímetro Inicial",
                        ),
                        validator: (value) => value!.isEmpty
                            ? "Horímetro Inicial é obrigatório."
                            : null,
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
                        validator: (value) => value!.isEmpty
                            ? "Horímetro Final é obrigatório."
                            : null,
                      ),
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
                const SizedBox(height: 10),
                const Text("Data e Horários*"),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Inicial*"),
                          const Text("Inicial*"),
                          ElevatedButton(
                            onPressed: () => _selecionarHorario(context, true),
                            child: Text(_horarioInicial != null
                                ? _formatarData(_horarioInicial!)
                                : "Selecione"),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text("Final*"),
                          const Text("Final*"),
                          ElevatedButton(
                            onPressed: () => _selecionarHorario(context, false),
                            child: Text(_horarioFinal != null
                                ? _formatarData(_horarioFinal!)
                                : "Selecione"),
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
                    onPressed: _avancar,
                    child: const Text(
                      'Avançar',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Exibe o último registro, se existir
                if (listaDeRegistros.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "Último Registro:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text(
                          "Matrícula: ${listaDeRegistros.last['matricula'] ?? 'Não informado'}"),
                      subtitle: Text(
                        "Horário Inicial: ${listaDeRegistros.last['horarioInicial'] ?? 'Não informado'}\n"
                        "Horário Final: ${listaDeRegistros.last['horarioFinal'] ?? 'Não informado'}",
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **Formata corretamente os horários armazenados**
  String _formatarData(dynamic valor) {
    if (valor == null || valor == "Não informado") return "Não informado";
    try {
      final DateTime dateTime =
          (valor is DateTime) ? valor : DateTime.parse(valor);
      return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(dateTime);
    } catch (e) {
      return "Formato inválido";
    }
  }

  /// **Criação de Campos de Texto**
  Widget _buildTextField(
      String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        validator: (value) => value!.isEmpty ? "Campo obrigatório" : null,
      ),
    );
  }
}
