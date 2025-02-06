import 'dart:async';
import 'package:flutter/material.dart';
import 'package:senior/data/core/widgets/base_layout.dart';
import 'package:senior/data/features/dbo/pages/DetailsRegister_page.dart';
import 'package:senior/data/features/dbo/pages/RegisterPublic_page.dart';
import 'package:senior/data/features/home_page.dart';
import 'package:senior/data/features/auth/login_page.dart';
import 'package:senior/data/features/horaextras/profile/profile_page.dart';
import 'package:senior/data/core/network/notification_services.dart';

import 'data/global_data.dart';
// import 'package:senior/data/src/services/hora_extra_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    return MaterialApp(
      navigatorKey: globalNavigatorKey,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/homepage': (context) => HomePage(),
        // Rota removida: '/dboHome'
        '/registerpublic': (context) => BaseLayout(body: RegisterPublicDBO()),
        '/detailsregister': (context) => BaseLayout(
                body: DetailsregisterPage(
              registros: listaDeRegistros,
            )),
        '/profile': (context) => BaseLayout(body: ProfilePage()),
      },
    );
  }
}
