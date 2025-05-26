import 'package:workmanager/workmanager.dart';
import 'dart:isolate';
import 'package:flutter/material.dart';

import '../model/storage_data_model.dart';
import '../model/http_connection_model.dart';
import '../model/config_setting_model.dart';
import 'notification_service.dart';

// 백그라운드 작업의 고유 이름
const String CHECK_ITEMS_TASK = "check_items_task";

// 백그라운드 작업 콜백 함수
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == CHECK_ITEMS_TASK) {
        await checkItemsAndNotify();
      }
      return Future.value(true);
    } catch (e) {
      print('Background task error: $e');
      return Future.value(false);
    }
  });
}

// 백그라운드 서비스 초기화 - 기존 함수는 남겨두되 main.dart에서 직접 초기화하도록 변경
Future<void> initializeBackgroundService() async {
  // 이 함수는 이제 main.dart에서 직접 초기화하므로 비워둠
  // 기존 코드를 남겨두어 호환성 유지
  print('Background service initialization is now handled in main.dart');
}

// 아이템 확인 및 알림 전송 로직
Future<void> checkItemsAndNotify() async {
  try {
    // 1. 서버 설정 로드
    final configSetting = ConfigSetting();
    await configSetting.loadConfig();

    // 2. HTTP 연결 설정
    final httpConnection = HttpConnection();
    httpConnection.setLocalhost(configSetting.isLocalhost);
    httpConnection.setUrl(configSetting.url);
    httpConnection.setPort(configSetting.port);

    // 3. 스토리지 데이터 가져오기
    final storageData = StorageData();
    final items = await httpConnection.getStorage();
    storageData.setStorageItems(items);

    // 4. 알림 서비스 초기화
    final notificationService = NotificationService();
    await notificationService.initialize();

    // 5. 방치된 아이템 확인 (24시간 이상 방치된 아이템)
    final abandonedItems = storageData.getAbandonedItems(
      Duration(hours: 24 * 7),
    );

    // 6. 방치된 아이템이 있으면 알림 전송
    for (var item in abandonedItems) {
      final String uuid = item['uuid'] ?? 'unknown';
      final String nickname = item['nickname'] ?? '알 수 없는 항목';

      await notificationService.showNotification(
        id: uuid.hashCode,
        title: '방치된 항목 알림',
        body: '$nickname이(가) 7일 이상 방치되었습니다.',
      );
    }
  } catch (e) {
    print('Error in checkItemsAndNotify: $e');
  }
}
