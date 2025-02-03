import 'dart:async';
import 'package:flutter/material.dart';
import 'package:senior/data/core/network/api_client.dart';
import 'package:senior/data/core/routers/app_router.dart';
import 'package:senior/data/core/network/notification_services.dart';
// import 'package:senior/data/src/services/hora_extra_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationServices.init();

  _scheduleDailyCheck(); // Agendar a verificação diária

  configureDio();
  runApp(const MyApp());
}

void _scheduleDailyCheck() {
  Timer(Duration(seconds: 5), () {
    // HoraExtraService.checkForYesterdayHoraExtra();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter,
      debugShowCheckedModeBanner: false,
      title: 'APP',
    );
  }
}
