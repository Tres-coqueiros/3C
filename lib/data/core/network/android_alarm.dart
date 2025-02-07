// import 'dart:async';
// import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
// import 'package:senior/data/core/network/api_services.dart';
// import 'package:senior/data/core/network/notification_services.dart';

// class BackgroundService {
//   static final GetServices getServices = GetServices();

//   static Future<void> checkHorasExtras() async {
//     try {
//       final List<Map<String, dynamic>> colaboradores =
//           await getServices.getCollaborators();

//       for (var colaborador in colaboradores) {
//         if (colaborador['ListHorasExtras'] != null &&
//             colaborador['ListHorasExtras'].isNotEmpty) {
//           await NotificationService.showNotification(
//             title: 'Hora Extra Detectada',
//             body: '${colaborador['NOMFUN']} possui horas extras registradas.',
//           );
//         }
//       }
//     } catch (e) {
//       print("Erro ao verificar horas extras: $e");
//     }
//   }

//   static Future<void> startBackgroundTask() async {
//     await AndroidAlarmManager.periodic(
//       const Duration(minutes: 1),
//       0,
//       checkHorasExtras,
//       wakeup: true,
//       rescheduleOnReboot: true,
//     );
//   }
// }
