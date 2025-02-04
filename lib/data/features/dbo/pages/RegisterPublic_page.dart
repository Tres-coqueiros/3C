import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

  DateTime? _horarioInicial;
  DateTime? _horarioFinal;
  List<Map<String, dynamic>> listaLimite = [];

  /// **Selecionar Data e Hora com Formatação Correta**
  void _selecionarHorario(BuildContext context, bool isInicial) {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      locale: LocaleType.pt, // Define para pt-BR
      onConfirm: (dateTime) {
        setState(() {
          if (isInicial) {
            _horarioInicial = dateTime;
          } else {
            _horarioFinal = dateTime;
          }
        });
      },
    );
  }

  /// **Avançar para a Próxima Tela**
  void _avancar() {
    if (_formKey.currentState!.validate()) {
      final novoRegistro = {
        'matricula': _matriculaController.text,
        'nomeCoordenador': _coordenadorController.text,
        'patrimonio': _patrimonioController.text,
        'horarioInicial': _horarioInicial?.toIso8601String() ?? 'Não informado',
        'horarioFinal': _horarioFinal?.toIso8601String() ?? 'Não informado',
        'horimetroInicial': _horimetroInicialController.text,
        'horimetroFinal': _horimetroFinalController.text,
      };

      setState(() {
        listaLimite.add(novoRegistro);
      });

      // Agora navega para RegisterActivity com os dados corretos
      context.go('/registeractivity', extra: {
        'dados': List.from(listaLimite),
        'informacoesGerais': {
          'matricula': _matriculaController.text,
          'coordenador': _coordenadorController.text,
          'patrimonio': _patrimonioController.text,
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastro de Atividades"),
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
                    "Coordenador"),
                _buildTextField("Patrimônio*", _patrimonioController,
                    "Digite o Patrimônio"),
                const SizedBox(height: 10),
                const Text("Horários*"),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
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
                const SizedBox(height: 10),
                const Text("Horímetro"),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField("Horímetro Inicial",
                          _horimetroInicialController, "Horímetro Inicial"),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField("Horímetro Final",
                          _horimetroFinalController, "Horímetro Final"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _avancar,
                  child: const Text("Avançar"),
                ),
                const SizedBox(height: 20),
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
                                        "Coordenador: ${item['nomeCoordenador']}"),
                                    Text("Patrimônio: ${item['patrimonio']}"),
                                    Text(
                                        "Horário Inicial: ${_formatarData(item['horarioInicial'])}"),
                                    Text(
                                        "Horário Final: ${_formatarData(item['horarioFinal'])}"),
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
                    : const Text("Nenhum registro encontrado."),
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
