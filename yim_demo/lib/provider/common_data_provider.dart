import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../model/http_connection_model.dart';
import '../model/storage_data_model.dart';
import '../model/config_setting_model.dart';
//import '../model/compare_date_model.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../model/notification_model.dart'; // 알림 모델 임포트

class CommonDataProvider extends ChangeNotifier {
  HttpConnection httpConnection = HttpConnection();
  StorageData storageData = StorageData();
  ConfigSetting configSetting = ConfigSetting();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  CommonDataProvider() {
    _initConfig(); // 생성자에서 초기 설정 로드
    _initNotifications(); // 알림 초기화 추가
  }

  Future<void> _initNotifications() async {
    // 알림 초기화 설정
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

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await requestNotificationPermissions();
    print('알림 초기화 완료');
  }

  Future<void> requestNotificationPermissions() async {
    // Android 13 (API level 33) 이상에서는 알림 권한을 명시적으로 요청해야 함
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _initConfig() async {
    await configSetting.loadConfig(); // ini 설정 로드

    // 로드된 설정으로 HttpConnection 초기화
    httpConnection.setLocalhost(configSetting.isLocalhost);
    httpConnection.setUrl(configSetting.url);
    httpConnection.setPort(configSetting.port);

    refreshData(); // 데이터 새로고침
  }

  Future<void> changeHttpConnection(
    bool isLocalhost,
    String url,
    String port,
  ) async {
    httpConnection.setLocalhost(isLocalhost);
    httpConnection.setUrl(url);
    httpConnection.setPort(port);

    await configSetting.setServerConfig(isLocalhost, url, port);

    storageData.clearStorageData(); // 기존 데이터 초기화
    //refreshData();
    notifyListeners();
  }

  Future<void> refreshData() async {
    try {
      storageData.setStorageItems(await httpConnection.getStorage());
      storageData.setTempItems(await httpConnection.getTemp());
      storageData.setBackgroundImage(
        await httpConnection.getImage('getBackground'),
      );

      notifyListeners();
    } catch (e) {
      print('Error refreshing Data: $e');
    }
  }

  Future<List<dynamic>> getStorageItems() async {
    return storageData.storageItems;
  }

  Future<Image?> getBackgroundImage() async {
    return storageData.backgroundImage;
  }

  // 현재 서버 설정 정보 반환
  bool getIsLocalhost() => configSetting.isLocalhost;
  String getServerUrl() => configSetting.url;
  String getServerPort() => configSetting.port;

  Future<bool> changeNickname(String uuid, String nickname) async {
    try {
      httpConnection.get('updateNickname/$uuid/$nickname');
      notifyListeners();
      return true;
    } catch (e) {
      print('Error changing nickname: $e');
      return false;
    }
  }

  void resetAll() {
    httpConnection.get('reset');
    notifyListeners();
  }

  Future<void> sendTestNotification(String title, String body) async {
    final notificationModel = NotificationModel(
      flutterLocalNotificationsPlugin,
    );
    await notificationModel.showNotification(title, body);
  }
}
