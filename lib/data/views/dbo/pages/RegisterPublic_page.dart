import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:senior/data/core/interface/app_interface.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/features/dbo/pages/RegisterActivity_Page.dart';
import 'package:senior/data/global_data.dart';
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

  List<Cultura> getCulturaFiltrada = [];
  List<Safra> getSafraFiltrada = [];
  List<Talhoes> getTalhoesFiltrada = [];

  @override
  void initState() {
    super.initState();
    fetchSafra();
    fetchCiclo();
    fetchCultura();
    fetchTalhoes();
    fetchOperador();
    getSafraFiltrada = getSafra;
    getCulturaFiltrada = getCultura;
    getTalhoesFiltrada = getTalhoes;
  }

  void fetchOperador() async {
    try {
      final result = await getServices.getOperador();
      setState(() {
        getOperador = result
            .map((data) => Operador(
                Codigo: data['Codigo'] ?? 0,
                Nome: data['Nome'] ?? 'Sem identificação'))
            .toList();
      });
    } catch (error) {
      print('Erro ao buscar talhoes: $error');
    }
  }

  void fetchTalhoes() async {
    try {
      final result = await getServices.getTalhao();
      setState(() {
        getTalhoes = result
            .map((data) => Talhoes(
                  Codigo: data['Codigo'] ?? 0,
                  Identificacao: data['Identificacao'] ?? 'Sem identificação',
                  Safra: data['Safra'] ?? 0,
                  Fazenda: data['Fazenda'] ?? 0,
                ))
            .toList();
      });
      getTalhoesFiltrada = getTalhoes;
    } catch (error) {
      print('Erro ao buscar talhoes: $error');
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
      print('Erro ao buscar culturas: $error');
    }
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
      getSafraFiltrada = getSafra;
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
                Safra: data['Safra'],
                Cultura: data['Cultura']))
            .toList();
      });
    } catch (error) {
      print('Error ao buscar ciclos: $error');
    }
  }

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
        'operacoes': []
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
                SearchableDropdown(
                    items: getOperador,
                    itemLabel: (operador) => operador.Nome,
                    onItemSelected: (operador) {
                      print('Operador selecionado: ${operador.Nome}');
                    }),
                const SizedBox(height: 8),
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
                _buildTextField('Safra', safraController, "Selecione a safra",
                    list: getSafraFiltrada, readOnly: true),
                _buildTextField("Fazenda", fazendaController, "Fazenda"),
                _buildTextField("Cultura", culturaController, "Cultura",
                    list: getCulturaFiltrada, readOnly: true),
                _buildTextField("Talhão", talhaoController, "Talhão",
                    list: getTalhoesFiltrada, readOnly: true),
                const SizedBox(height: 16),
                const Text("Jornada de Trabalho",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_horarioError)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '⚠️ Jornada Final deve ser maior que o Inicial!',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 24),
                ButtonComponents(
                  onPressed: _salvarRegistro,
                  text: 'Salvar e Avançar',
                  textColor: AppColorsComponents.hashours,
                  backgroundColor: AppColorsComponents.primary,
                  fontSize: 18,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 37, vertical: 12),
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
      String label, TextEditingController controller, String hint,
      {List list = const [],
      bool isNumeric = false,
      Function(dynamic value)? onChanged,
      bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
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
        readOnly: readOnly,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTimePicker(String label, String? time, bool isInicial) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        ElevatedButton(
          onPressed: () => _selecionarHorario(context, isInicial),
          child:
              Text(time ?? "Selecione", style: const TextStyle(fontSize: 14)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
