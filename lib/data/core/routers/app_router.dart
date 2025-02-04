import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/features/auth/login_page.dart';
import 'package:senior/data/features/dbo/pages/DetailsRegister_page.dart';
import 'package:senior/data/features/dbo/pages/RegisteractivityPage.dart';
import 'package:senior/data/features/dbo/pages/RegisterPublic_page.dart';
import 'package:senior/data/features/dbo/pages/home_page.dart';
import 'package:senior/data/features/home_page.dart';
import 'package:senior/data/features/horaextras/pages/list_colaboradores_page.dart';
import 'package:senior/data/features/horaextras/profile/profile_page.dart';
import 'package:senior/data/features/widgets/base_layout.dart';

/// Lista global para armazenar os registros
List<Map<String, dynamic>> listaDeRegistros = [];

/// Tela de opções gerais com botão para acessar os registros
class OpcoesGeraisOuRegistrosPage extends StatelessWidget {
  const OpcoesGeraisOuRegistrosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Opções")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                context.go('/registerpublic');
              },
              child: const Text("Cadastrar"),
            ),
            ElevatedButton(
              onPressed: () {
                context.go(
                  '/detailsregister',
                  extra: {'dados': List.from(listaDeRegistros)},
                );
              },
              child: const Text("Registros"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Configuração do GoRouter corrigido
final GoRouter AppRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => LoginPage()),
    GoRoute(path: '/homepage', builder: (context, state) => HomePage()),
    GoRoute(
        path: '/listcolaboradores',
        builder: (context, state) => BaseLayout(body: ListColaboradores())),
    GoRoute(
        path: '/dboHome',
        builder: (context, state) =>
            BaseLayout(body: OpcoesGeraisOuRegistrosPage())),
    GoRoute(
        path: '/registerpublic',
        builder: (context, state) => BaseLayout(body: RegisterPublicDBO())),
    GoRoute(
      path: '/detailsregister',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>? ?? {};
        final registros = (extras['dados'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];

        print("Registros recebidos na tela de detalhes: $registros"); // Debug

        return BaseLayout(
          body: DetailsregisterPage(dados: registros),
        );
      },
    ),
    GoRoute(
      path: '/registeractivity',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>? ?? {};
        final dados = extras['dados'] as List<dynamic>? ?? [];
        final informacoesGerais =
            extras['informacoesGerais'] as Map<String, dynamic>? ?? {};

        return BaseLayout(
          body: RegisteractivityPage(
              dados: dados, informacoesGerais: informacoesGerais),
        );
      },
    ),
    GoRoute(
        path: '/profile',
        builder: (context, state) => BaseLayout(body: ProfilePage())),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Rota não encontrada: ${state.uri.toString()}')),
  ),
);
