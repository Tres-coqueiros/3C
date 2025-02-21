// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:senior/data/core/repository/client_repository.dart';
import 'package:senior/data/core/routers/app_router.dart';
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
      routerConfig: appRouter,
      debugShowCheckedModeBanner: true,
      title: 'Senior',
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            ErrorListener(),
          ],
        );
      },
    );
  }
}
