import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  List<Map<String, dynamic>> selectedLocais = [];

  int? localSelecionado;
  int? materialSelecionado;

  bool showCard = false;

  @override
  void initState() {
    super.initState();
    fetchSolicitarMaterial();
  }

  void _addProduct() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        products.add({
          'category': materialController.text,
          'material': materialController.text,
          'group': groupController.text,
          'quantitative': quantitativeController.text,
        });
        materialController.clear();
        groupController.clear();
        quantitativeController.clear();
      });
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
          _buildMaterialList(), // Lista de materiais do banco de dados
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
                _buildMaterialList(), // Lista de materiais do banco de dados
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

                groupController.text = material['GRUPO'].toString();
                materialController.text = material['MATERIAL'].toString();
                showCard = true;
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
        : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (context, index) => const Divider(
              height: 20,
              thickness: 1,
              color: Colors.grey,
            ),
            itemBuilder: (context, index) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                shadowColor: Colors.grey.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            products[index]['material'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                products.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Categoria: ${products[index]['category']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Grupo: ${products[index]['group']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantidade: ${products[index]['quantitative']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildMaterialList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: getMaterialSolicitacao.length,
      separatorBuilder: (context, index) => const Divider(
        height: 20,
        thickness: 1,
        color: Colors.grey,
      ),
      itemBuilder: (context, index) {
        final material = getMaterialSolicitacao[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          shadowColor: Colors.grey.withOpacity(0.3),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material['MATERIAL'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Grupo: ${material['GRUPO']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Saldo: ${material['SALDO']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Preço Médio: ${material['PCOMEDIO']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return ButtonComponents(
      onPressed: () => context.go('/solicitacao'),
      text: 'Solicitar Compra',
      textColor: Colors.white,
      backgroundColor: AppColorsComponents.primary,
      fontSize: 18,
      padding: const EdgeInsets.symmetric(horizontal: 37, vertical: 12),
      textAlign: Alignment.center,
    );
  }
}
