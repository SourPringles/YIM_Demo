import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer? _timer;

  Future<void> init() async {
    // 알림 초기화 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // 알림 권한 요청
    await _requestPermissions();

    //startPeriodicNotifications(intervalMinutes: 3);
  }

  Future<void> _requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // 주기적 알림 시작
  void startPeriodicNotifications({
    required int intervalMinutes,
    required int count,
  }) {
    // 기존 타이머 취소
    _timer?.cancel();

    // 새 타이머 시작
    _timer = Timer.periodic(
      Duration(minutes: intervalMinutes),
      (timer) => showNotification(
        id: timer.tick,
        title: '정기 알림',
        body: '$count개의 반찬이 7일 이상 방치되었습니다.',
      ),
    );
  }

  // 주기적 알림 중지
  void stopPeriodicNotifications() {
    _timer?.cancel();
    _timer = null;
  }

  // 알림 표시
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'periodic_notifications',
          '주기적 알림',
          channelDescription: '일정 시간마다 표시되는 알림입니다.',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
