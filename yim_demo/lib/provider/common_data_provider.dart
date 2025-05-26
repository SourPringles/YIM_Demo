import 'package:flutter/material.dart';

import '../model/http_connection_model.dart';
import '../model/storage_data_model.dart';
import '../model/config_setting_model.dart';
import '../notification/background_service.dart';
import '../notification/notification_service.dart';
//import '../model/compare_date_model.dart';

class CommonDataProvider extends ChangeNotifier {
  HttpConnection httpConnection = HttpConnection();
  StorageData storageData = StorageData();
  ConfigSetting configSetting = ConfigSetting();

  CommonDataProvider() {
    _initConfig(); // 생성자에서 초기 설정 로드
  }

  Future<void> _initConfig() async {
    await configSetting.loadConfig(); // ini 설정 로드

    // 로드된 설정으로 HttpConnection 초기화
    httpConnection.setLocalhost(configSetting.isLocalhost);
    httpConnection.setUrl(configSetting.url);
    httpConnection.setPort(configSetting.port);

    // 백그라운드 서비스는 이제 main.dart에서 초기화하므로 제거
    // await initializeBackgroundService();

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

  // 방치된 아이템 체크 (UI에서 직접 확인할 수 있는 메서드)
  List<Map<String, dynamic>> checkAbandonedItems(Duration threshold) {
    return storageData.getAbandonedItems(threshold);
  }

  // 수동으로 백그라운드 작업 즉시 실행 (필요한 경우)
  Future<void> checkAbandonedItemsNow() async {
    try {
      final abandonedItems = storageData.getAbandonedItems(Duration(hours: 24));
      final service = NotificationService();
      await service.initialize();
      await service.initialize();

      for (var item in abandonedItems) {
        final String uuid = item['uuid'] ?? 'unknown';
        final String nickname = item['nickname'] ?? '알 수 없는 항목';

        await service.showNotification(
          id: uuid.hashCode,
          title: '방치된 항목 알림',
          body: '$nickname이(가) 24시간 이상 방치되었습니다.',
        );
      }
    } catch (e) {
      print('Error checking abandoned items: $e');
    }
  }
}
