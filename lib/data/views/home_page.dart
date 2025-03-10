import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/core/repository/api_repository.dart';
import 'package:senior/data/views/widgets/base_layout.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';

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

      print('result: $result');
      if (result.isNotEmpty) {
        useCargos = result[0]['usu_tbcarges'] ?? 'Desconhecido';
      }

      setState(() {
        listColaborador = result;
      });
    } catch (error) {
      print('Erro ao buscar matrícula: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      body: Scaffold(
        backgroundColor: AppColorsComponents.background,
        body: Center(
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              _buildExpandableButton(
                context,
                title: "Recursos Humanos",
                color: AppColorsComponents.primary,
                expanded: isRhExpanded,
                onPressed: () {
                  setState(() {
                    isRhExpanded = !isRhExpanded;
                  });
                },
              ),
              if (isRhExpanded)
                Column(
                  children: [
                    _buildButton(
                      context,
                      title: "Horas Extras",
                      color: AppColorsComponents.primary,
                      visible: useCargos == 'S',
                      onPressed: () => context.go('/listcolaboradores'),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              _buildSectionTitle("PCM"),
              _buildButton(
                context,
                title: "Projeto BDO",
                color: AppColorsComponents.secondary,
                onPressed: () => context.go('/registerpublic'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableButton(
    BuildContext context, {
    required String title,
    required Color color,
    required bool expanded,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 4.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            Icon(expanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String title,
    required Color color,
    required VoidCallback onPressed,
    bool visible = true,
  }) {
    if (!visible) return SizedBox();

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 4.0,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
