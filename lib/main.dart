import 'package:flutter/material.dart';
import 'package:senior/data/dio/api_client.dart';
import 'package:senior/data/src/components/list_colaboradores.dart';
import 'package:senior/data/src/layout/base_layout.dart';
import 'package:senior/data/src/page/home_page.dart';
import 'package:senior/data/src/page/list_hora_extra.dart';
import 'package:senior/data/src/page/login.dart';
import 'package:senior/data/src/page/profile_page.dart';

void main() {
  configureDio();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/homepage': (context) => HomePage(),
        '/listaColaboradores': (context) => BaseLayout(
            body: ListHoraExtra(
                colaborador:
                    ModalRoute.of(context)!.settings.arguments as Colaborador)),
        '/profile': (context) => BaseLayout(body: ProfilePage()),
      },
    );
  }
}
