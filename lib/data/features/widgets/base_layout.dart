import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/features/auth/auth_services.dart';
import 'package:senior/data/features/horaextras/navigation/navigation_page.dart';

class BaseLayout extends StatelessWidget {
  final PostAuth postAuth = PostAuth();
  final Widget body;

  BaseLayout({super.key, required this.body});

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
        backgroundColor: const Color.fromARGB(255, 0, 204, 51),
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
