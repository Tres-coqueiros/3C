import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/features/auth/auth_services.dart';
import 'package:senior/data/features/dbo/pages/DetailsRegister_page.dart';
import 'package:senior/data/features/horaextras/navigation/navigation_page.dart';
import 'package:senior/data/features/widgets/components/app_colors_components.dart';

class BaseLayout extends StatelessWidget {
  final PostAuth postAuth = PostAuth();
  final Widget body;

  BaseLayout({super.key, required this.body});

  /// **Navega para a tela de registros**
  void _mostrarRegistros(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BaseLayout(
              body: DetailsregisterPage(
            registros: [],
          )),
        ));
  }

  void Exit(BuildContext context) async {
    try {
      await postAuth.authlogout();
      context.go('/');
    } catch (error) {
      print('Error ao ecerrar app: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao tentar sair do aplicativo'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Três Coqueiros'),
        backgroundColor: AppColorsComponents.primary,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.exit_to_app_outlined),
              color: Colors.white,
              onPressed: () => {Exit(context)}),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => _mostrarRegistros(
                context), // Agora leva para a tela de registros
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF3F7FB),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(child: body),
          ModernNavigationBar(),
        ],
      ),
    );
  }
}
