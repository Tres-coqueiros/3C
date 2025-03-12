import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/core/repository/exceptions_network.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
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

  List<Map<String, dynamic>> getMaterialSolicitacao = [];

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
        materialController.clear();
        groupController.clear();
        quantitativeController.clear();
      });
    }
  }

  void _submitRequest() {
    print('Produtos adicionados: $products');
  }

  void fetchSolicitarMaterial() async {
    try {
      try {
        final result = await getServices.getMaterialSolicitacao();

        setState(() {
          getMaterialSolicitacao = result;
        });
        print('result $result');
      } catch (error) {
        print('Erro ao buscar gestor: $error');
        ErrorNotifier.showError("Erro ao buscar gestor: $error");
      }
    } catch (error) {}
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SearchableDropdown(
                      items: getMaterialSolicitacao,
                      itemLabel: (material) => material['MATERIAL'],
                      onItemSelected: (material) {
                        setState(() {
                          groupController.text = material['GRUPO'];
                          materialController.text = material['MATERIAL'];
                        });
                      },
                      labelText: "Código Material",
                      hintText: "Selecione o operador",
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                        'Material', materialController, Icons.category),
                    const SizedBox(height: 10),
                    _buildTextField(
                        'Material', materialController, Icons.build),
                    const SizedBox(height: 10),
                    _buildTextField('Grupo de Materiais', groupController,
                        Icons.group_work),
                    const SizedBox(height: 10),
                    _buildTextField(
                        'Quantidade', quantitativeController, Icons.numbers),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              ButtonComponents(
                onPressed: _addProduct,
                text: 'Adicionar Item',
                textColor: Colors.white,
                backgroundColor: AppColorsComponents.primary,
                fontSize: 18,
                padding:
                    const EdgeInsets.symmetric(horizontal: 37, vertical: 12),
                textAlign: Alignment.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 300, // Define um tamanho fixo para a lista
                child: products.isEmpty
                    ? const Center(
                        child: Text('Nenhum produto adicionado ainda',
                            style: TextStyle(fontSize: 16)))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: products.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(products[index]['material'],
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  Text(
                                      'Categoria: ${products[index]['category']}'),
                                  Text('Grupo: ${products[index]['group']}'),
                                  Text(
                                      'Quantidade: ${products[index]['quantitative']}'),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          products.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              ButtonComponents(
                onPressed: () => context.go('/solicitacao'),
                text: 'Solicitar Compra',
                textColor: Colors.white,
                backgroundColor: AppColorsComponents.primary,
                fontSize: 18,
                padding:
                    const EdgeInsets.symmetric(horizontal: 37, vertical: 12),
                textAlign: Alignment.center,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Preencha este campo' : null,
    );
  }
}
