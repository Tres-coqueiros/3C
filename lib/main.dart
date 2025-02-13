import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior/data/app_database.dart';
import 'package:senior/data/core/routers/app_router.dart';
import 'package:senior/data/core/network/notification_services.dart';
import 'package:senior/data/features/horaextras/pages/error_notifier_page.dart';
//import 'package:senior/data/database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o serviço de notificações antes de rodar o app.
  await NotificationService.init();

  // Inicializa o banco de dados
  final database = AppDatabase();

  // Executa o aplicativo
  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final AppDatabase database;

  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
      ],
      child: MaterialApp.router(
        // Configuração do roteador (utilizando GoRouter)
        routerConfig: appRouter,

        // Exibe a banner de debug; altere para false em produção.
        debugShowCheckedModeBanner: false,

        // Título do aplicativo.
        title: 'Senior',

        // O builder permite sobrepor widgets; adicionamos o ErrorListener
        builder: (context, child) {
          return Stack(
            children: [
              child!, // Conteúdo principal gerenciado pelo GoRouter
              ErrorListener(), // Widget para exibição de notificações de erro
            ],
          );
        },
      ),
    );
  }
}
