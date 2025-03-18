import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/core/interface/app_interface.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/core/repository/exceptions_network.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/app_text_components.dart';
import 'package:senior/data/views/widgets/components/button_components.dart';
import 'package:senior/data/views/widgets/components/search_components.dart';

class SolicitarPage extends StatefulWidget {
  @override
  _SolicitarPageState createState() => _SolicitarPageState();
}

class _SolicitarPageState extends State<SolicitarPage> {
  final GetServices getServices = GetServices();
  final PostServices postServices = PostServices();

  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> products = [];
  TextEditingController materialController = TextEditingController();
  TextEditingController groupController = TextEditingController();
  TextEditingController quantitativeController = TextEditingController();
  TextEditingController locaisController = TextEditingController();
  TextEditingController pcoMedioController = TextEditingController();
  TextEditingController quantidadeASerCompradaController =
      TextEditingController();

  List<Map<String, dynamic>> getMaterialSolicitacao = [];
  List<Map<String, dynamic>> getMatricula = [];
  List<Map<String, dynamic>> selectedLocais = [];
  List<Map<String, dynamic>> getGestor = [];

  int? localSelecionado;
  int? materialSelecionado;
  int? grupoSelecionado;

  String usuario = '';
  int? matricula;

  String gestor = '';
  int gestorId = 0;

  @override
  void initState() {
    super.initState();
    fetchSolicitarMaterial();
    fetchMatricula();
    fetchGestor();
  }

  void fetchGestor() async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final result = await getServices.getGestor();
      if (result.isNotEmpty) {
        gestor = result[0]['GESTOR'];
        gestorId = result[0]['GESTOR_ID'];
      }

      print('gestor: $gestorId');
      setState(() {
        getGestor = result;
      });
    } catch (error) {
      ErrorNotifier.showError('Erro ao buscar gestor: $error');
    }
  }

  Map<String, dynamic> _createProductData() {
    return {
      'MATERIAL': materialController.text,
      'GRUPO': groupController.text,
      'QUANTIDADE': quantitativeController.text,
      'LOCAL': locaisController.text,
      'PCOMEDIO': pcoMedioController.text,
      'QUANTIDADE_ASER_COMPRADA': quantidadeASerCompradaController.text,
      'gestor': gestor,
      'gestor_id': gestorId
    };
  }

  void _addProduct() {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = _createProductData();
      setState(() {
        products.add(data);
        materialController.clear();
        groupController.clear();
        quantitativeController.clear();
        quantidadeASerCompradaController.clear();
        locaisController.clear();
        pcoMedioController.clear();
        localSelecionado = null;
        materialSelecionado = null;
      });
    }
  }

  void addSubmit() async {
    if (products.isEmpty) {
      ErrorNotifier.showError("Adicione pelo menos um item antes de enviar.");
      return;
    }

    final Map<String, dynamic> data = {
      "usuario": usuario,
      "usuario_id": matricula,
      "data_solicitacao": DateTime.now().toIso8601String(),
      "itens": products
          .map((material) => {
                "produto": material['MATERIAL'],
                "quantidade": material['QUANTIDADE_ASER_COMPRADA'],
                "preco_unitario": material['PCOMEDIO'],
                "subtotal": (double.tryParse(
                            material['QUANTIDADE_ASER_COMPRADA'].toString()) ??
                        0) *
                    (double.tryParse(material['PCOMEDIO'].toString()) ?? 0),
                "local": material['LOCAL'],
                "grupo": material['GRUPO'],
              })
          .toList(),
    };

    try {
      print('Enviando dados: $data');
      bool success = await postServices.postSolicitacao(data);
      if (success) {
        context.go('/solicitacao');
      } else {
        ErrorNotifier.showError("Erro ao enviar pedido.");
      }
    } catch (error) {
      ErrorNotifier.showError("Erro ao enviar pedido: $error");
    }
  }

  void fetchMatricula() async {
    try {
      final result = await getServices.getLogin();

      if (result.isNotEmpty) {
        usuario = result[0]['nomfun'];
        matricula = result[0]['numcad'];
      }

      setState(() {
        getMatricula = result;
      });
    } catch (error) {
      ErrorNotifier.showError("Erro ao buscar matricula: $error");
    }
  }

  void fetchSolicitarMaterial() async {
    try {
      final result = await getServices.getMaterialSolicitacao();
      setState(() {
        getMaterialSolicitacao = result;
        print('result: $result');
      });
    } catch (error) {
      ErrorNotifier.showError("Erro ao buscar gestor: $error");
    }
  }

  List<Map<String, dynamic>> getUniqueMaterials() {
    final seen = <int>{};
    return getMaterialSolicitacao
        .where((material) {
          final idMaterial = material['ID_MATERIAL'];
          if (idMaterial is int) {
            return seen.add(idMaterial);
          } else if (idMaterial is String) {
            final id = int.tryParse(idMaterial);
            if (id != null) {
              return seen.add(id);
            }
          }
          return false;
        })
        .map((material) => {
              'ID_MATERIAL': material['ID_MATERIAL'],
              'MATERIAL': material['MATERIAL'],
              'GRUPO': material['GRUPO'],
              'SUBGRUPO': material['SUBGRUPO'],
              'SALDO': material['SALDO'],
              'PCOMEDIO': material['PCOMEDIO'],
            })
        .toList();
  }

  List<Map<String, dynamic>> getLocaisByMaterial(int materialId) {
    return getMaterialSolicitacao
        .where((material) => material['ID_MATERIAL'] == materialId)
        .map((material) => {
              'LocaisId': material['LocaisId'],
              'LOCAIS': material['LOCAIS'],
              'SALDO': material['SALDO'],
              'PCOMEDIO': material['PCOMEDIO'],
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 800;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: isMobile ? _buildMobileLayout() : _buildWebLayout(),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildForm(),
          const SizedBox(height: 20),
          _buildProductList(),
          const SizedBox(height: 20),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildWebLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildForm(),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProductList(),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildSubmitButton(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          SearchableDropdown(
            items: getUniqueMaterials(),
            itemLabel: (material) => material['ID_MATERIAL'].toString(),
            onItemSelected: (material) {
              setState(() {
                materialSelecionado = material['ID_MATERIAL'];
                selectedLocais = getLocaisByMaterial(materialSelecionado!);
                grupoSelecionado = material['GRUPO'];

                groupController.text = material['GRUPO'].toString();
                materialController.text = material['MATERIAL'].toString();
              });
            },
            labelText: "Código Material",
            hintText: "Selecione o Código do Material",
          ),
          const SizedBox(height: 10),
          AppTextComponents(
            label: 'Material',
            controller: materialController,
            hint: 'Material',
            readOnly: true,
          ),
          const SizedBox(height: 10),
          AppTextComponents(
            label: 'Grupo de Material',
            controller: groupController,
            hint: 'Grupo de Material',
            readOnly: true,
          ),
          const SizedBox(height: 10),
          SearchableDropdown(
            items: selectedLocais,
            itemLabel: (local) => local['LOCAIS'],
            onItemSelected: (local) {
              print('Local selecionado: ${local['LOCAIS']}');
              setState(() {
                locaisController.text = local['LOCAIS'].toString();
                quantitativeController.text = local['SALDO'].toString();
                pcoMedioController.text = local['PCOMEDIO'].toString();
              });
            },
            labelText: "Local",
            hintText: "Selecione o Local",
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppTextComponents(
                  label: 'Quantidade',
                  controller: quantitativeController,
                  hint: 'Quantidade',
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppTextComponents(
                  label: 'Preço Médio',
                  controller: pcoMedioController,
                  hint: 'Preço Médio',
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppTextComponents(
                  label: 'Quantidade a ser comprada',
                  hint: 'Digite a quantidade',
                  controller: quantidadeASerCompradaController,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 5),
              ButtonComponents(
                onPressed: _addProduct,
                textColor: Colors.white,
                backgroundColor: AppColorsComponents.primary,
                fontSize: 14,
                padding: const EdgeInsets.symmetric(vertical: 4),
                textAlign: Alignment.center,
                icon: Icons.add,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return products.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 50,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 10),
                Text(
                  'Nenhum produto adicionado ainda',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Text(
                  'ITENS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final material = products[index];

                    return SizedBox(
                      width: 330,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        shadowColor: Colors.grey.withOpacity(0.3),
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                material['MATERIAL']?.toString() ??
                                    'Desconhecido',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(height: 35),
                              _buildInfoText('Grupo', material['GRUPO']),
                              _buildInfoText('Saldo', material['QUANTIDADE']),
                              _buildInfoText(
                                  'Preço Médio', material['PCOMEDIO']),
                              _buildInfoText('Qtd. a comprar',
                                  material['QUANTIDADE_ASER_COMPRADA']),
                              _buildInfoText('Local', material['LOCAL']),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }

  Widget _buildInfoText(String label, dynamic value) {
    return Text(
      '$label: ${value?.toString() ?? 'N/A'}',
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey[700],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ButtonComponents(
      onPressed: () => addSubmit(),
      text: 'Solicitar Compra',
      textColor: Colors.white,
      backgroundColor: AppColorsComponents.primary,
      fontSize: 18,
      padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 12),
      textAlign: Alignment.center,
    );
  }
}
