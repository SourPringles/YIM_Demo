import 'package:flutter/material.dart';

import '../model/http_connection_model.dart';
import '../model/storage_data_model.dart';
import '../model/config_setting_model.dart';
//import '../model/compare_date_model.dart';
import '../service/notification_service.dart';

class CommonDataProvider extends ChangeNotifier {
  HttpConnection httpConnection = HttpConnection();
  StorageData storageData = StorageData();
  ConfigSetting configSetting = ConfigSetting();
  final NotificationService _notificationService = NotificationService();
  bool _notificationsActive = false;

  CommonDataProvider() {
    _notificationService.init(); // 알림 서비스 초기화
    _initConfig(); // 생성자에서 초기 설정 로드
    // 초기 알림은 _initConfig() 내에서 refreshData() 후에 처리되므로 여기서는 호출하지 않음
  }

  // 알림 시작 메서드
  void _startNotifications() {
    // 방치된 항목 상세 디버깅
    int abandonedCount = storageData.getAbandonedItemsCount();
    // print("방치된 항목 개수: $abandonedCount");
    //
    // // 현재 아이템 로깅
    // print("저장소 아이템 수: ${storageData.storageItems.length}");
    // print("임시 아이템 수: ${storageData.tempItems.length}");
    //
    if (_notificationsActive) {
      // 이미 활성화된 경우 기존 알림 중지
      _notificationService.stopPeriodicNotifications();
      _notificationsActive = false;
    }

    // 방치된 항목이 있을 때만 알림 시작
    if (abandonedCount > 0) {
      _notificationService.startPeriodicNotifications(
        intervalMinutes: 1,
        count: abandonedCount,
      );
      _notificationsActive = true;
      // print("알림 활성화됨: $abandonedCount개 항목 방치됨");
    } else {
      // print("방치된 항목이 없어 알림이 비활성화됨");
    }
  }

  Future<void> _initConfig() async {
    await configSetting.loadConfig(); // ini 설정 로드

    // 로드된 설정으로 HttpConnection 초기화
    httpConnection.setLocalhost(configSetting.isLocalhost);
    httpConnection.setUrl(configSetting.url);
    httpConnection.setPort(configSetting.port);

    await refreshData(); // 데이터 새로고침 (await 추가)
    // refreshData 내부에서 _startNotifications()가 호출됨
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
    await refreshData(); // 데이터 다시 로드 (await 추가)
    notifyListeners();
  }

  Future<void> refreshData() async {
    try {
      // print("데이터 새로고침 시작");

      // 데이터 로드
      var storageItems = await httpConnection.getStorage();
      var tempItems = await httpConnection.getTemp();

      // print("서버에서 받은 저장소 아이템 수: ${storageItems.length}");
      // print("서버에서 받은 임시 아이템 수: ${tempItems.length}");
      //
      // 타임스탬프 확인 및 수정 (필요한 경우)
      // _ensureValidTimestamps(storageItems);
      // _ensureValidTimestamps(tempItems);

      // 데이터 설정
      storageData.setStorageItems(storageItems);
      storageData.setTempItems(tempItems);
      storageData.setBackgroundImage(
        await httpConnection.getImage('getBackground'),
      );

      // 알림 업데이트
      _startNotifications();

      notifyListeners();
    } catch (e) {
      //print('Error refreshing Data: $e');
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
      //print('Error changing nickname: $e');
      return false;
    }
  }

  void resetAll() {
    httpConnection.get('reset');
    notifyListeners();
  }
}
