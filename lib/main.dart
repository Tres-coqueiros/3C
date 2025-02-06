import 'dart:async';
import 'package:flutter/material.dart';
import 'package:senior/data/core/routers/app_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:senior/data/core/network/notification_services.dart';

import 'data/global_data.dart';
// import 'package:senior/data/src/services/hora_extra_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Corrige a formatação de data para o Brasil
  await initializeDateFormatting('pt_BR', null);

  await NotificationServices.init();

  _scheduleDailyCheck(); // Agendar a verificação diária

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
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'APP',
    );
  }
}
