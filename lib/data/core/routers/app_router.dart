import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/core/widgets/base_layout.dart';
import 'package:senior/data/features/auth/login_page.dart';
import 'package:senior/data/features/dbo/pages/DetailsRegister_page.dart';
import 'package:senior/data/features/dbo/pages/RegisterActivity_page.dart';
import 'package:senior/data/features/dbo/pages/RegisterPublic_page.dart';
import 'package:senior/data/features/horaextras/profile/profile_page.dart';
import 'package:senior/data/global_data.dart'; // Importa a variável global

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    // Rota para cadastro direto (RegisterPublicDBO)
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
    GoRoute(
      path: '/registeractivity',
      builder: (context, state) => BaseLayout(
        body: RegisterActivityPage(
          dados: listaDeRegistros,
          informacoesGerais: {},
        ),
      ),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => BaseLayout(body: const ProfilePage()),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Rota não encontrada: ${state.uri.toString()}'),
    ),
  ),
);
