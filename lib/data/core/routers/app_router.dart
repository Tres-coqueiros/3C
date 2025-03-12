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

// Import das telas de solicitações:
import 'package:senior/data/views/suprimentos/pages/solicitacoes_list_page.dart';
import 'package:senior/data/views/suprimentos/pages/detalhes_solicitacao_page.dart';

import 'package:senior/data/global_data.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    // 1. Página Inicial: Login
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),

    // 2. Home Page
    GoRoute(
      path: '/homepage',
      builder: (context, state) => const HomePage(),
    ),

    // 3. Exemplo de DBO Público
    GoRoute(
      path: '/registerpublic',
      builder: (context, state) => BaseLayout(
        body: RegisterPublicDBO(),
      ),
    ),

    // 4. Exemplo de Detalhes
    GoRoute(
      path: '/detailsregister',
      builder: (context, state) => BaseLayout(
        body: DetailsregisterPage(registros: listaDeRegistros),
      ),
    ),

    // 5. Exemplo de Registro de Atividade
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

    // 6. Perfil
    GoRoute(
      path: '/profile',
      builder: (context, state) => BaseLayout(body: ProfilePage()),
    ),

    // 7. Lista de Colaboradores
    GoRoute(
      path: '/listcolaboradores',
      builder: (context, state) => BaseLayout(body: ListColaboradores()),
    ),

    // ========== ROTAS DE SOLICITAÇÃO ==========
    // A) Lista de Solicitações (singular sem 's')
    GoRoute(
      path: '/solicitacao',
      builder: (context, state) => BaseLayout(
        body: const SolicitacoesListPage(),
      ),
    ),

    // B) Detalhes de uma Solicitação (singular sem 's')
    GoRoute(
      path: '/solicitacao/detalhe',
      builder: (context, state) {
        final solicitacao = state.extra as Map<String, dynamic>;
        return BaseLayout(
          body: DetalhesSolicitacaoPage(solicitacao: solicitacao),
        );
      },
    ),

    // C) [NOVA ROTA] Redundante para quem chamar '/solicitacoes/detalhes'
    // Aponta para a mesma tela de detalhes, sem alterar o código "já corrigido"
    GoRoute(
      path: '/solicitacoes/detalhes',
      builder: (context, state) {
        final solicitacao = state.extra as Map<String, dynamic>;
        return BaseLayout(
          body: DetalhesSolicitacaoPage(solicitacao: solicitacao),
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Rota não encontrada: ${state.uri.toString()}'),
    ),
  ),
);
