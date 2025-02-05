import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/core/network/api_services.dart';
import 'package:senior/data/features/widgets/base_layout.dart';
import 'package:senior/data/features/widgets/components/app_colors_components.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetServices getServices = GetServices();

  List<Map<String, dynamic>> listColaborador = [];
  String use_Cargos = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchMatricula();
  }

  void fetchMatricula() async {
    try {
      final result = await getServices.getLogin();

      if (result.isNotEmpty) {
        use_Cargos = result['getLogin']['usu_tbcarges'] ?? 'Desconhecido';
      }

      setState(() {
        listColaborador = [result['getLogin']];
      });
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      body: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 350,
                height: 60,
                child: use_Cargos == 'S'
                    ? ElevatedButton(
                        onPressed: () => context.go('/listcolaboradores'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColorsComponents.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          'HORA EXTRAS',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      )
                    : SizedBox(),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 350,
                height: 60,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/dboHome'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppColorsComponents.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'DBO',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
