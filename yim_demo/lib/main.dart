import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io' show Platform;

import 'view/main_view.dart';
import 'provider/common_data_provider.dart';
import 'theme/app_theme.dart';
import 'notification/notification_service.dart';
import 'notification/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 알림 서비스 초기화
    final notificationService = NotificationService();
    await notificationService.initialize();

    // 모바일 플랫폼에서만 Workmanager 초기화
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        // Workmanager 직접 초기화
        await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

        // 백그라운드 작업 등록
        await Workmanager().registerPeriodicTask(
          CHECK_ITEMS_TASK,
          CHECK_ITEMS_TASK,
          frequency: const Duration(minutes: 15),
          constraints: Constraints(networkType: NetworkType.connected),
        );
        print('Workmanager 초기화 성공');
      } catch (e) {
        print('Workmanager 초기화 실패: $e');
      }
    } else {
      print('현재 플랫폼에서는 Workmanager를 지원하지 않습니다: ${Platform.operatingSystem}');
    }

    runApp(const MainApp());
  } catch (e) {
    print('Error initializing app: $e');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CommonDataProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MainView(),
        theme: AppTheme.tossTheme,
      ),
    );
  }
}
