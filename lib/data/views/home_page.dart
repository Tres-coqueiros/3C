import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior/data/core/provider/app_provider_departament.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/views/widgets/base_layout.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetServices getServices = GetServices();

  List<Map<String, dynamic>> listColaborador = [];
  String useCargos = "";
  bool isRhExpanded = false;

  @override
  void initState() {
    super.initState();
    fetchMatricula();
  }

  void fetchMatricula() async {
    try {
      final result = await getServices.getLogin();

      if (result.isNotEmpty) {
        useCargos = result[0]['usu_tbcarges'] ?? 'Desconhecido';
      }
      print('result: $useCargos');

      setState(() {
        listColaborador = result;
      });
    } catch (error) {
      print('Erro ao buscar matrícula: $error');
    }
  }

  void _showDepartmentSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsComponents.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return Consumer<AppProviderDepartament>(
          builder: (context, provider, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Selecione um Departamento",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColorsComponents.background,
                    ),
                  ),
                  ListTile(
                    title: Text("Recursos Humanos"),
                    textColor: AppColorsComponents.background,
                    onTap: () {
                      provider.setSelectedDepartament("Recursos Humanos");
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text("PCM"),
                    textColor: AppColorsComponents.background,
                    onTap: () {
                      provider.setSelectedDepartament("PCM");
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text("Suprimentos"),
                    textColor: AppColorsComponents.background,
                    onTap: () {
                      provider.setSelectedDepartament("Suprimentos");
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String selectedDepartment =
        Provider.of<AppProviderDepartament>(context).selectedDepartament;

    return BaseLayout(
      body: Scaffold(
        backgroundColor: AppColorsComponents.background,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              if (selectedDepartment.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Selecione algum Departamento",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: AppColorsComponents.primary,
                      ),
                    ),
                  ),
                ),
              if (useCargos == 'S' && selectedDepartment == "Recursos Humanos")
                _buildButton(
                  context,
                  title: "Horas Extras",
                  color: AppColorsComponents.primary,
                  icon: Icons.access_time,
                  onPressed: () => context.go('/listcolaboradores'),
                ),
              if (selectedDepartment == "PCM")
                _buildButton(
                  context,
                  title: "BDO",
                  color: AppColorsComponents.secondary,
                  icon: Icons.build,
                  onPressed: () => context.go('/registerpublic'),
                ),
              if (selectedDepartment == "Suprimentos")
                _buildButton(
                  context,
                  title: "Solicitação de Compra",
                  color: AppColorsComponents.primary,
                  icon: Icons.shopping_cart,
                  onPressed: () => context.go('/registerpublic'),
                )
              else if (useCargos == 'N')
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColorsComponents.hashours,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Sem acesso a esse projeto",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => {_showDepartmentSelection(context)},
          backgroundColor: AppColorsComponents.primary,
          child: Icon(Icons.business, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String title,
    required Color color,
    required VoidCallback onPressed,
    required IconData icon,
    bool visible = true,
  }) {
    if (!visible) return SizedBox();
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24, color: Colors.white),
        label: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 8.0,
          shadowColor: Colors.black.withOpacity(0.3),
          padding: EdgeInsets.symmetric(horizontal: 16.0),
        ),
      ),
    );
  }
}
