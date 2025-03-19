import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/views/auth/auth_services.dart';
import 'package:senior/data/views/pages/loading_page.dart';
import 'package:senior/data/views/widgets/components/app_colors_components.dart';
import 'package:senior/data/views/widgets/components/button_components.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return LoadingPage(message: "Carregando...");
      },
    );

    try {
      bool success = await postAuth.authuser(matricula);

      if (success) {
        Navigator.pop(context);
        context.go('/dashboard');
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro no login. Tente novamente."),
            backgroundColor: AppColorsComponents.error,
          ),
        );
      }
    } catch (error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro: $error"),
          backgroundColor: AppColorsComponents.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsComponents.primary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColorsComponents.primary,
              AppColorsComponents.primary2,
            ],
            stops: [
              0.7,
              0.5,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Card(
                elevation: 20.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(21.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: AnimatedContainer(
                          duration: Duration(seconds: 1),
                          curve: Curves.easeInOut,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.asset(
                              'assets/images/logo.png',
                              height: 120.0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40.0),
                      // Campo do número do crachá
                      TextField(
                        controller: _crachaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Número Crachá',
                          labelStyle: TextStyle(
                              color: const Color.fromARGB(179, 0, 0, 0)),
                          hintText: 'Digite seu crachá',
                          // hintStyle: TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          prefixIcon: Icon(Icons.badge,
                              color: const Color.fromARGB(179, 0, 0, 0)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(
                                color: const Color.fromARGB(255, 15, 15, 15)),
                          ),
                        ),
                      ),
                      SizedBox(height: 30.0),
                      ButtonComponents(
                        onPressed: () => login(context),
                        text: 'Entrar',
                        textColor: Colors.white,
                        backgroundColor: AppColorsComponents.primary,
                        fontSize: 18,
                        padding:
                            EdgeInsets.symmetric(horizontal: 37, vertical: 12),
                        textAlign: Alignment.center,
                        isLoading:
                            isLoading, // Adicionado suporte ao carregamento
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
