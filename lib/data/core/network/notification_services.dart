import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:senior/data/features/horaextras/pages/list_colaboradores_page.dart';

class NotificationServices {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Inicializa o plugin de notificações
    await _notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
      if (response != null) {
        Navigator.of(globalNavigatorKey.currentContext!).push(MaterialPageRoute(
          builder: (context) => ListColaboradores(),
        ));
      }
    });
  }

  static Future<void> showNotification(
      {required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'hora_extra_id',
      'Notificações de Hora Extra',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(0, title, body, notificationDetails);
  }
}

// Para facilitar o uso do Navigator em qualquer lugar do aplicativo,
// crie uma chave global para o Navigator
final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();
