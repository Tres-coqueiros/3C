import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:senior/data/src/services/notification_services.dart';

class HomePage extends StatefulWidget {
  final NotificationService notificationService;
  HomePage({required this.notificationService});

  @override
  _Homepage createState() => _Homepage();
}

class _Homepage extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received: ${message.notification?.title}');
      widget.notificationService.showOvertimeNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Text('Tela principal')),
        ],
      ),
    );
  }
}
