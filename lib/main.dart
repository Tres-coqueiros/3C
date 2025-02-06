import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:senior/data/core/network/android_alarm.dart';
import 'package:senior/data/core/network/api_client.dart';
import 'package:senior/data/core/routers/app_router.dart';
import 'package:senior/data/core/network/notification_services.dart';
import 'package:senior/data/features/horaextras/pages/error_notifier_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  await BackgroundService.startBackgroundTask();
  await NotificationService.init();
  configureDio();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter,
      debugShowCheckedModeBanner: true,
      title: '',
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
