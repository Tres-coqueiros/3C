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

  List<Ciclo> getCiclo = [];
  List<Safra> getSafra = [];
  List<Talhoes> getTalhoes = [];
  List<Cultura> getCultura = [];
  List<Operador> getOperador = [];
  List<Fazenda> getFazenda = [];

  List<Cultura> getCulturaFiltrada = [];
  List<Safra> getSafraFiltrada = [];
  List<Talhoes> getTalhoesFiltrada = [];
  List<Fazenda> getFazendaFiltrada = [];

  @override
  void initState() {
    super.initState();
    fetchSafra();
    fetchCiclo();
    fetchCultura();
    fetchTalhoes();
    fetchOperador();
    fetchFazenda();
    getSafraFiltrada = getSafra;
    getCulturaFiltrada = getCultura;
    getTalhoesFiltrada = getTalhoes;
    getFazendaFiltrada = getFazenda;
  }

  void fetchOperador() async {
    try {
      final result = await getServices.getOperador();
      setState(() {
        getOperador = result
            .map((data) => Operador(
                  Codigo: data['Codigo'] ?? 0,
                  Nome: data['Nome'] ?? 'Sem identificação',
                ))
            .toList();
      });
    } catch (error) {
      // Trate erro se necessário
    }
  }

  void fetchFazenda() async {
    try {
      final result = await getServices.getFazenda();
      setState(() {
        getFazenda = result
            .map((data) => Fazenda(
                  Codigo: data['Codigo'],
                  Descricao: data['Descricao'] ?? 'Sem Descricao',
                  Sequencial: data['Sequencial'],
                ))
            .toList();
      });
      getFazendaFiltrada = getFazenda;
    } catch (error) {
      // Trate erro se necessário
    }
  }

  void fetchTalhoes() async {
    try {
      final result = await getServices.getTalhao();
      setState(() {
        getTalhoes = result
            .map((data) => Talhoes(
                  Codigo: data['Codigo'],
                  Identificacao: data['Identificacao'] ?? 'Sem identificação',
                  Safra: data['Safra'],
                  Fazenda: data['Fazenda'],
                ))
            .toList();
      });
      getTalhoesFiltrada = getTalhoes;
    } catch (error) {
      // Trate erro se necessário
    }
  }

  void fetchCultura() async {
    try {
      final result = await getServices.getCultura();
      setState(() {
        getCultura = result
            .map((data) => Cultura(
                  Codigo: data['Codigo'],
                  Descricao: data['Descricao'],
                ))
            .toList();
      });
      getCulturaFiltrada = getCultura;
    } catch (error) {
      // Trate erro se necessário
    }
  }

  void fetchSafra() async {
    try {
      final result = await getServices.getSafra();
      setState(() {
        getSafra = result
            .map((data) => Safra(
                  Codigo: data['Codigo'],
                  Descricao: data['Descricao'],
                ))
            .toList();
      });
      getSafraFiltrada = getSafra;
    } catch (error) {
      // Trate erro se necessário
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
                  Safra: data['Safra'],
                  Cultura: data['Cultura'],
                ))
            .toList();
      });
    } catch (error) {
      // Trate erro se necessário
    }
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
      final registro = {
        'matricula': _matriculaController.text,
        'horarioInicial': _horarioInicial,
        'horarioFinal': _horarioFinal,
        'operacoes': [],
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Operador
                SearchableDropdown(
                  items: getOperador,
                  itemLabel: (operador) => operador.Nome,
                  onItemSelected: (operador) {
                    // ...
                  },
                ),
                const SizedBox(height: 8),

                // Ciclos
                SearchableDropdown<Ciclo>(
                  items: getCiclo,
                  itemLabel: (ciclo) => ciclo.Descricao,
                  onItemSelected: (ciclo) {
                    final culturaid = getCultura
                        .where((cultura) => ciclo.Cultura == cultura.Codigo)
                        .toList();
                    final safrasid = getSafra
                        .where((safra) => safra.Codigo == ciclo.Safra)
                        .toList();

                    setState(() {
                      getSafraFiltrada = safrasid;
                      getCulturaFiltrada = culturaid;
                      if (safrasid.isNotEmpty) {
                        safraController.text = safrasid[0].Descricao;
                      }
                      if (culturaid.isNotEmpty) {
                        culturaController.text = culturaid[0].Descricao;
                      }
                      if (safrasid.isNotEmpty) {
                        getTalhoesFiltrada = getTalhoes
                            .where(
                                (talhao) => talhao.Safra == safrasid[0].Codigo)
                            .toList();
                      } else {
                        getTalhoesFiltrada = [];
                      }
                    });
                  },
                  labelText: "Ciclos",
                  hintText: "Selecione o ciclo",
                ),
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
                SearchableDropdown(
                  items: getTalhoesFiltrada,
                  itemLabel: (talhao) => talhao.Identificacao,
                  onItemSelected: (talhao) {
                    setState(() {
                      fazendaController.text =
                          _getFazendaDescricaoBySequencial(talhao.Fazenda);
                    });
                  },
                  labelText: "Talhões",
                ),

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

                // Aqui inserimos os botões p/ data/hora
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
