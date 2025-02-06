import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePageDBO extends StatefulWidget {
  const HomePageDBO({super.key});

  @override
  _HomePageDBOState createState() => _HomePageDBOState();
}

class _HomePageDBOState extends State<HomePageDBO> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // 🔹 Garante centralização total na tela
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // 🔹 Centraliza verticalmente
          crossAxisAlignment:
              CrossAxisAlignment.center, // 🔹 Centraliza horizontalmente
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 30,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                context.go('/registerpublic'); // 🔹 Navega para Cadastro
              },
              child: const Text('Cadastrar'),
            ),
            const SizedBox(height: 20), // 🔹 Espaço entre os botões
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600], // 🔹 Cor de fundo do botão
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 30,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                context.go('/detailsregister'); // 🔹 Navega para Registros
              },
              child: const Text(
                'Registros',
                style: TextStyle(color: Colors.white), // 🔹 Texto branco
              ),
            ),
          ],
        ),
      ),
    );
  }
}
