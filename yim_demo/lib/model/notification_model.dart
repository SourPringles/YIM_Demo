import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationModel {
  final FlutterLocalNotificationsPlugin notificationsPlugin;

  NotificationModel(this.notificationsPlugin);

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'your_channel_id',
          '알림 채널',
          channelDescription: '앱 알림을 표시합니다',
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

    await notificationsPlugin.show(
      0, // 알림 ID (여러 알림을 구분하기 위해 다른 ID 사용)
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> showPeriodNotifications(String title, String body) async {
    // 주기적인 알림 설정
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'periodic_channel_id',
          '주기적 알림',
          channelDescription: '주기적으로 표시되는 알림',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // 15분마다 알림 표시
    await notificationsPlugin.periodicallyShow(
      0, // 알림 ID
      title,
      body,
      RepeatInterval.daily, // 매일
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }
}
