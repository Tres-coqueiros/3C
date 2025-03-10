import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/views/auth/auth_services.dart';
import 'package:senior/data/views/dbo/pages/DetailsRegister_page.dart';
import 'package:senior/data/views/horaextras/pages/navigation_page.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/sidebar_components.dart';

class BaseLayout extends StatelessWidget {
  final PostAuth postAuth = PostAuth();
  final Widget body;

  BaseLayout({super.key, required this.body});

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
      print('Error ao encerrar app: $error');
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
            onPressed: () => _mostrarRegistros(context),
          ),
        ],
      ),
      drawer: Drawer(
        shadowColor: AppColorsComponents.hashours,
        child: Column(
          children: [Expanded(child: SidebarComponents())],
        ),
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
