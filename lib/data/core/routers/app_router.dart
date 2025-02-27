// File: lib/data/core/routers/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/views/auth/login_page.dart';
import 'package:senior/data/views/home_page.dart';
import 'package:senior/data/views/horaextras/pages/list_colaboradores_page.dart';
import 'package:senior/data/views/horaextras/pages/profile_page.dart';
import 'package:senior/data/views/widgets/base_layout.dart';
import 'package:senior/data/views/dbo/pages/DetailsRegister_page.dart';
import 'package:senior/data/views/dbo/pages/RegisterActivity_page.dart';
import 'package:senior/data/views/dbo/pages/RegisterPublic_page.dart';
import 'package:senior/data/global_data.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/homepage',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/registerpublic',
      builder: (context, state) => BaseLayout(body: RegisterPublicDBO()),
    ),
    GoRoute(
      path: '/detailsregister',
      builder: (context, state) => BaseLayout(
        body: DetailsregisterPage(registros: listaDeRegistros),
      ),
    ),
    // Rota para cadastro de atividades sem passar 'atividade'
    GoRoute(
      path: '/registeractivity',
      builder: (context, state) => BaseLayout(
          body: RegisterActivityPage(
        dados: listaDeRegistros,
        informacoesGerais: {}, atividade: {},
        // Removido: atividade: {}
      )),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => BaseLayout(body: ProfilePage()),
    ),
    GoRoute(
      path: '/listcolaboradores',
      builder: (context, state) => BaseLayout(body: ListColaboradores()),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Rota não encontrada: ${state.uri.toString()}'),
    ),
  ),
);
