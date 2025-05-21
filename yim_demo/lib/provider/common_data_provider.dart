import 'package:flutter/material.dart';

import '../model/http_connection_model.dart';
import '../model/storage_data_model.dart';
import '../model/config_setting_model.dart';
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

    refreshData(); // 데이터 새로고침
  }

  void changeHttpConnection(bool isLocalhost, String url, String port) async {
    httpConnection.setLocalhost(isLocalhost);
    httpConnection.setUrl(url);
    httpConnection.setPort(port);

    await configSetting.setServerConfig(isLocalhost, url, port);

    storageData.clearStorageData(); // 기존 데이터 초기화
    refreshData();
    notifyListeners();
  }

  void refreshData() async {
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

  List<dynamic> getStorageItems() {
    return storageData.storageItems;
  }

  Image? getBackgroundImage() {
    return storageData.backgroundImage;
  }

  // 현재 서버 설정 정보 반환
  bool getIsLocalhost() => configSetting.isLocalhost;
  String getServerUrl() => configSetting.url;
  String getServerPort() => configSetting.port;

  bool changeNickname(String uuid, String nickname) {
    try {
      httpConnection.get('rename/$uuid/$nickname');
      notifyListeners();
      return true;
    } catch (e) {
      print('Error changing nickname: $e');
      return false;
    }
  }
}
