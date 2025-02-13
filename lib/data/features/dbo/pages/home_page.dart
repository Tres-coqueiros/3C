import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:senior/data/app_database.dart';
//import 'package:senior/data/database/app_database.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.green[800],
      ),
      body: FutureBuilder<int>(
        future:
            database.obterNumeroDeAtividades(), // Obtém contagem de registros
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildButton(
                  context,
                  "Cadastro DBO",
                  Icons.assignment_add,
                  Colors.blue,
                  "/registerpublic",
                ),
                const SizedBox(height: 20),
                _buildButton(
                  context,
                  "Histórico de Registros (${snapshot.data ?? 0})", // Mostra número de registros
                  Icons.history,
                  Colors.green,
                  "/detailsregister",
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// **Método para criar botões estilizados**
  Widget _buildButton(BuildContext context, String label, IconData icon,
      Color color, String route) {
    return SizedBox(
      width: 250,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        icon: Icon(icon, size: 20),
        label: Text(label),
        onPressed: () => context.push(route),
      ),
    );
  }
}
