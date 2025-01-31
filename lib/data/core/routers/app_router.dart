import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/core/widgets/base_layout.dart';
import 'package:senior/data/features/auth/login_page.dart';
import 'package:senior/data/features/dbo/pages/DetailsRegister_page.dart';
import 'package:senior/data/features/dbo/pages/RegisterPublic_page.dart';
import 'package:senior/data/features/dbo/pages/home_page.dart';
import 'package:senior/data/features/home_page.dart';
import 'package:senior/data/features/horaextras/pages/list_colaboradores_page.dart';
import 'package:senior/data/features/horaextras/profile/profile_page.dart';

final GoRouter AppRouter = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => LoginPage()),
      GoRoute(path: '/homepage', builder: (context, state) => HomePage()),
      GoRoute(
          path: '/listcolaboradores',
          builder: (context, state) => BaseLayout(body: ListColaboradores())),
      GoRoute(
          path: '/dboHome',
          builder: (context, state) => BaseLayout(body: HomePageDBO())),
      GoRoute(
          path: '/registerpublic',
          builder: (context, state) => BaseLayout(body: RegisterPublicDBO())),
      GoRoute(
          path: '/detailsregister',
          builder: (context, state) => BaseLayout(body: DetailsregisterPage())),
      GoRoute(
          path: 'profile',
          builder: (context, state) => BaseLayout(body: ProfilePage())),
    ],
    errorBuilder: (context, state) => Scaffold(
          body: Center(
            child: Text('Rota não encontrada: ${state.namedLocation('name')}'),
          ),
        ));
