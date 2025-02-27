import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:senior/data/core/interface/app_interface.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/global_data.dart';
import 'package:senior/data/views/dbo/pages/RegisterActivity_page.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/button_components.dart';
import 'package:senior/data/views/widgets/components/search_components.dart';

class RegisterPublicDBO extends StatefulWidget {
  @override
  _RegisterPublicDBOState createState() => _RegisterPublicDBOState();
}

class _RegisterPublicDBOState extends State<RegisterPublicDBO> {
  final GetServices getServices = GetServices();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController safraController = TextEditingController();
  final TextEditingController talhaoController = TextEditingController();
  final TextEditingController culturaController = TextEditingController();
  final TextEditingController fazendaController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();

  String? _horarioInicial;
  String? _horarioFinal;

  bool _horarioError = false;
  bool _horimetroError = false;

  @override
  void initState() {
    super.initState();
  }

  /// Mapeia o sequencial para uma descrição específica (se precisar).
  String _getFazendaDescricaoBySequencial(dynamic sequencial) {
    switch (sequencial.toString()) {
      case '1':
        return 'SPZ - MAURO';
      case '14':
        return 'BRN - MAURO';
      case '16':
        return 'GNT - MAURO';
      case '1.377':
        return 'ALG - MAURO';
      case '11.124':
        return 'BJR - MAURO';
      default:
        return 'Fazenda não encontrada';
    }
  }

  /// Escolher data/hora
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

  void _salvarRegistro() {
    setState(() {
      _horarioError = _horarioInicial == null || _horarioFinal == null;
    });

    if (_formKey.currentState!.validate() &&
        !_horarioError &&
        !_horimetroError) {
      // Monta o registro parcial (NÃO adiciona em listaDeRegistros para evitar duplicação)
      final registro = {
        'matricula': _matriculaController.text,
        'horarioInicial': _horarioInicial,
        'horarioFinal': _horarioFinal,
        'operacoes': [],
      };

      // Removido: listaDeRegistros.add(registro);

      // Navega para a próxima tela (RegisterActivityPage)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterActivityPage(
            dados: listaDeRegistros, // Lista global atual
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
      // Sem AppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Operador
                // SearchableDropdown(
                //   items: getOperador,
                //   itemLabel: (operador) => operador.Nome,
                //   onItemSelected: (operador) {
                //     // ...
                //   },
                // ),
                const SizedBox(height: 8),

                // Ciclos
                // SearchableDropdown<Ciclo>(
                //   items: getCiclo,
                //   itemLabel: (ciclo) => ciclo.Descricao,
                //   onItemSelected: (ciclo) {
                //     final culturaid = getCultura
                //         .where((cultura) => ciclo.Cultura == cultura.Codigo)
                //         .toList();
                //     final safrasid = getSafra
                //         .where((safra) => safra.Codigo == ciclo.Safra)
                //         .toList();

                //     setState(() {
                //       getSafraFiltrada = safrasid;
                //       getCulturaFiltrada = culturaid;
                //       if (safrasid.isNotEmpty) {
                //         safraController.text = safrasid[0].Descricao;
                //       }
                //       if (culturaid.isNotEmpty) {
                //         culturaController.text = culturaid[0].Descricao;
                //       }
                //       if (safrasid.isNotEmpty) {
                //         getTalhoesFiltrada = getTalhoes
                //             .where(
                //                 (talhao) => talhao.Safra == safrasid[0].Codigo)
                //             .toList();
                //       } else {
                //         getTalhoesFiltrada = [];
                //       }
                //     });
                //   },
                //   labelText: "Ciclos",
                //   hintText: "Selecione o ciclo",
                // ),
                const SizedBox(height: 8),

                // Safra
                _buildTextField(
                  'Safra',
                  safraController,
                  "Selecione a safra",
                  readOnly: true,
                ),
                // Cultura
                _buildTextField(
                  "Cultura",
                  culturaController,
                  "Cultura",
                  readOnly: true,
                ),

                // Talhões
                // SearchableDropdown(
                //   items: getTalhoesFiltrada,
                //   itemLabel: (talhao) => talhao.Identificacao,
                //   onItemSelected: (talhao) {
                //     setState(() {
                //       fazendaController.text =
                //           _getFazendaDescricaoBySequencial(talhao.Fazenda);
                //     });
                //   },
                //   labelText: "Talhões",
                // ),

                // Fazenda
                _buildTextField(
                  "Fazenda",
                  fazendaController,
                  "Fazenda",
                  readOnly: true,
                ),

                const SizedBox(height: 16),
                const Text(
                  "Jornada de Trabalho",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                // Botões p/ data/hora
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimePicker(
                          "Horário Inicial", _horarioInicial, true),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimePicker(
                          "Horário Final", _horarioFinal, false),
                    ),
                  ],
                ),

                if (_horarioError)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '⚠️ Jornada Final deve ser maior que o Inicial!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // (Campo de Matrícula, se quiser ativar, basta descomentar)
                // _buildTextField(
                //   "Matrícula",
                //   _matriculaController,
                //   "Digite a Matrícula",
                // ),

                // Botão
                ButtonComponents(
                  onPressed: _salvarRegistro,
                  text: 'Salvar e Avançar',
                  textColor: AppColorsComponents.hashours,
                  backgroundColor: AppColorsComponents.primary,
                  fontSize: 18,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 37,
                    vertical: 12,
                  ),
                  textAlign: Alignment.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    bool readOnly = false,
    List list = const [],
    bool isNumeric = false,
    Function(dynamic value)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? "Campo obrigatório" : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTimePicker(String label, String? time, bool isInicial) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        ElevatedButton(
          onPressed: () => _selecionarHorario(context, isInicial),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            time ?? "Selecione",
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
