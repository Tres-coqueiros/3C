import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                          labelText: 'Número do Crachá',
                          labelStyle: TextStyle(
                              color: const Color.fromARGB(179, 0, 0, 0)),
                          hintText: 'Digite seu crachá',
                          hintStyle: TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
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
                      // Botão de login com animação
                      ElevatedButton(
                        onPressed: isLoading ? null : () => login(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorsComponents.primary,
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          elevation: 20,
                          shadowColor: AppColorsComponents.primary,
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Entrar',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      SizedBox(height: 20.0),
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
