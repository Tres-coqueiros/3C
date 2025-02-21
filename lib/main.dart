// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:senior/data/core/routers/app_router.dart';
import 'package:senior/data/core/repository/notification_services.dart';
import 'package:senior/data/global_data.dart';
import 'package:senior/data/views/horaextras/pages/error_notifier_page.dart';

void main() async {
  // Garante que os widgets estejam inicializados antes de executar o app.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o serviço de notificações antes de rodar o app.
  await NotificationService.init();

  // Executa o aplicativo.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Configuração do roteador (utilizando GoRouter)
      routerConfig: appRouter,

      // Exibe a banner de debug; altere para false em produção.
      debugShowCheckedModeBanner: true,

      // Título do aplicativo.
      title: 'Senior',

      // O builder permite sobrepor widgets; neste caso, adicionamos o ErrorListener
      // para que ele possa exibir notificações de erros globalmente, sobrepondo as demais telas.
      builder: (context, child) {
        return Stack(
          children: [
            child!, // Conteúdo principal gerenciado pelo GoRouter
            ErrorListener(), // Widget para exibição de notificações de erro
          ],
        );
      },
    );
  }
}
