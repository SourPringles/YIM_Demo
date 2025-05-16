import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'view/mainView.dart';
import 'provider/commonDataProvider.dart';

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
      child: const MaterialApp(home: MainView()),
    );
  }
}
