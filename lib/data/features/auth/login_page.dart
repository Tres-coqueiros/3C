import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/features/horaextras/pages/list_colaboradores_page.dart';
import 'package:senior/data/features/auth/auth_services.dart';
import 'package:senior/data/features/widgets/components/app_colors_components.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final PostAuth postAuth = PostAuth();
  final _crachaController = TextEditingController();

  bool isLoading = false;

  void login(BuildContext context) async {
    final matricula = _crachaController.text.trim();

    if (matricula.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, insira o número do crachá.'),
          backgroundColor: AppColorsComponents.error,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      bool success = await postAuth.authuser(matricula);

      if (success) {
        context.go('/homepage');
      }
      _crachaController.clear();
    } catch (error) {
      String errorMessage = error.toString();
      if (errorMessage.isEmpty) {
        errorMessage = 'Ocorreu um erro inesperado.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColorsComponents.error,
        ),
      );
      print('erro ao fazer login: $error');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsComponents.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 120.0,
                      ),
                    ),
                    SizedBox(height: 40.0),
                    // Campo do número do crachá
                    TextField(
                      controller: _crachaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Número do Crachá',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: Icon(Icons.badge,
                            color: AppColorsComponents.primary),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    ElevatedButton(
                      onPressed: () => login(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorsComponents.primary,
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
