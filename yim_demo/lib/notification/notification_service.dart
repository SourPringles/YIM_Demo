import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 지원되지 않는 플랫폼에서는 초기화 건너뛰기
    if (!(Platform.isAndroid || Platform.isIOS)) {
      print('알림은 현재 플랫폼에서 지원되지 않습니다: ${Platform.operatingSystem}');
      return;
    }

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await _notificationsPlugin.initialize(initializationSettings);
      print('알림 서비스 초기화 성공');
    } catch (e) {
      print('알림 서비스 초기화 실패: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      print('알림 표시 건너뛰기 (지원되지 않는 플랫폼): $title - $body');
      return;
    }

    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
            'abandoned_items_channel',
            '방치된 항목 알림',
            channelDescription: '항목이 오랫동안 방치되었을 때 알림을 표시합니다',
            importance: Importance.max,
            priority: Priority.high,
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notificationsPlugin.show(id, title, body, notificationDetails);
    } catch (e) {
      print('알림 표시 실패: $e');
    }
  }
}
