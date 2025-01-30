import 'dart:async';
import 'package:flutter/material.dart';
import 'package:senior/data/src/layout/base_layout.dart';
import 'package:senior/data/src/page/home_page.dart';
import 'package:senior/data/src/page/login_page.dart';
import 'package:senior/data/src/page/profile_page.dart';
import 'package:senior/data/src/services/notification_services.dart';
import 'package:senior/data/src/services/hora_extra_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationServices.init();

  _scheduleDailyCheck(); // Agendar a verificação diária

  runApp(const MyApp());
}

void _scheduleDailyCheck() {
  Timer(Duration(seconds: 5), () {
    HoraExtraService.checkForYesterdayHoraExtra();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/homepage': (context) => HomePage(),
        '/profile': (context) => BaseLayout(body: ProfilePage()),
      },
    );
  }
}
