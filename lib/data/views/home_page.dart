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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(
                context,
                title: "HORA EXTRAS",
                color: AppColorsComponents.primary,
                visible: useCargos == 'S',
                onPressed: () => context.go('/listcolaboradores'),
              ),
              const SizedBox(height: 20),
              SizedBox(height: 20),
              _buildButton(
                context,
                title: "BDO",
                color: AppColorsComponents.secondary,
                onPressed: () => context.go('/registerpublic'),
              ),
            ],
          ),
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
