import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:senior/data/core/interface/app_interface.dart';

// Imports das suas páginas
import 'package:senior/data/views/auth/login_page.dart';
import 'package:senior/data/views/home_page.dart';
import 'package:senior/data/views/horaextras/pages/list_colaboradores_page.dart';
import 'package:senior/data/views/horaextras/pages/profile_page.dart';
import 'package:senior/data/views/pages/logsPage.dart';
import 'package:senior/data/views/suprimentos/pages/solicitar_page.dart';
import 'package:senior/data/views/widgets/base_layout.dart';
import 'package:senior/data/views/dbo/pages/DetailsRegister_page.dart';
import 'package:senior/data/views/dbo/pages/RegisterActivity_page.dart';
import 'package:senior/data/views/dbo/pages/RegisterPublic_page.dart';
import 'package:senior/data/views/suprimentos/pages/solicitacoes_list_page.dart';
import 'package:senior/data/views/suprimentos/pages/detalhes_solicitacao_page.dart';

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
      builder: (context, state) => BaseLayout(
        body: RegisterPublicDBO(),
      ),
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
          atividade: {},
        ),
      ),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => BaseLayout(body: ProfilePage()),
    ),
    GoRoute(
      path: '/listcolaboradores',
      builder: (context, state) => BaseLayout(body: ListColaboradores()),
    ),
    GoRoute(
      path: '/solicitacao',
      builder: (context, state) => BaseLayout(
        body: const SolicitacoesListPage(),
      ),
    ),
    GoRoute(
      path: '/solicitar',
      builder: (context, state) => BaseLayout(
        body: SolicitarPage(),
      ),
    ),
    GoRoute(
      path: '/solicitacao/detalhe',
      builder: (context, state) {
        final solicitacao = state.extra as Map<String, dynamic>;
        return BaseLayout(
          body: DetalhesSolicitacaoPage(solicitacao: solicitacao),
        );
      },
    ),
    GoRoute(
      path: '/solicitacoes/detalhes',
      builder: (context, state) {
        final solicitacao = state.extra as Map<String, dynamic>;
        return BaseLayout(
          body: DetalhesSolicitacaoPage(solicitacao: solicitacao),
        );
      },
    ),

    GoRoute(
      path: '/logs',
      builder: (context, state) {
        final logs = state.extra as List<LogEntry>? ?? [];
        return BaseLayout(body: LogsPage(logs: logs));
      },
    ),
    // GoRoute(
    //   path: '/logs',
    //   builder: (context, state) {
    //     // Se estiver passando logs via 'extra'
    //     final logs = state.extra as List<LogEntry>? ?? [];
    //     return LogsPage(logs: logs);
    //   },
    // ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Rota não encontrada: ${state.uri.toString()}'),
    ),
  ),
);
