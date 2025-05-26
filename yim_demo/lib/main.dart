import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view/main_view.dart';
import 'provider/common_data_provider.dart';
import 'theme/app_theme.dart';

void main() {
  try {
    runApp(const MainApp());
  } catch (e) {
    print('Error: $e');
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
        theme: AppTheme.tossTheme, // Toss 스타일 테마 적용
      ),
    );
  }
}
