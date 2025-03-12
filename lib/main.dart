import 'package:flutter/material.dart';
import 'package:senior/data/core/repository/client_repository.dart';
import 'package:senior/data/core/routers/app_router.dart'; // ✅ Certifique-se de que está importado corretamente
import 'package:senior/data/core/repository/notification_services.dart';
import 'package:senior/data/views/horaextras/pages/error_notifier_page.dart';

void main() async {
  configureDio();
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter, // ✅ Usa `appRouter` corretamente
      debugShowCheckedModeBanner: false,
      title: 'Senior',
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            ErrorListener(),
          ],
        );
      },
    );
  }
}
