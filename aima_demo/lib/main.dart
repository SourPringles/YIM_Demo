import 'package:flutter/material.dart';
import 'package:aima_demo/pages/mainpage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainPage(),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 1200),
            child: ClipRect(child: child),
          ),
        );
      },
    );
  }
}
