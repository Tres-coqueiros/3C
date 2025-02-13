import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//import 'package:senior/data/database/app_database.dart';
import 'package:senior/data/features/auth/login_page.dart';
import 'package:senior/data/features/home_page.dart';
import 'package:senior/data/features/horaextras/pages/profile_page.dart';
import 'package:senior/data/features/widgets/base_layout.dart';
import 'package:senior/data/features/dbo/pages/DetailsRegister_page.dart';
import 'package:senior/data/features/dbo/pages/RegisterActivity_page.dart';
import 'package:senior/data/features/dbo/pages/RegisterPublic_page.dart';

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
      builder: (context, state) => RegisterPublicDBO(),
    ),
    GoRoute(
      path: '/detailsregister',
      builder: (context, state) => BaseLayout(
        body: DetailsregisterPage(
          registros: [],
        ),
      ),
    ),
    GoRoute(
      path: '/registeractivity',
      builder: (context, state) {
        final atividade = state.extra as Map<String, dynamic>? ?? {};

        return BaseLayout(
          body: RegisterActivityPage(
            dados: [], // Lista inicial vazia (será carregada no banco)
            informacoesGerais: atividade, atividade: {},
          ),
        );
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => BaseLayout(body: ProfilePage()),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Rota não encontrada: ${state.uri.toString()}'),
    ),
  ),
);
