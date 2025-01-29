import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:senior/data/dio/api_client.dart';
import 'package:senior/data/src/components/list_colaboradores.dart';
import 'package:senior/data/src/layout/base_layout.dart';
import 'package:senior/data/src/page/home_page.dart';
import 'package:senior/data/src/page/list_hora_extra.dart';
import 'package:senior/data/src/page/login_page.dart';
import 'package:senior/data/src/page/profile_page.dart';
import 'package:senior/data/src/services/notification_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  final NotificationService notificationService = NotificationService();
  await notificationService.initialize();

  configureDio();
  runApp(MyApp(notificationService: notificationService));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;
  MyApp({required this.notificationService});

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'overtime_channel_id',
    'Overtime Channel',
    importance: Importance.max,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound('notification_sound'),
    largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/homepage': (context) =>
            HomePage(notificationService: notificationService),
        '/listaColaboradores': (context) => BaseLayout(
            body: ListHoraExtra(
                colaborador:
                    ModalRoute.of(context)!.settings.arguments as Colaborador)),
        '/profile': (context) => BaseLayout(body: ProfilePage()),
      },
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.messageId}');
}
