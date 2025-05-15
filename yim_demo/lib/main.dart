import 'package:flutter/material.dart';

import 'views/P_visualviewpage.dart';
import 'views/P_listviewpage.dart';
import 'views/P_uploadimagepage.dart';
import 'views/D_settingsdialog.dart';

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
    return MaterialApp(
      home: const HomePage(),
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // 화면 크기의 90%로 제한
            final width = constraints.maxWidth * 0.9;
            final height = constraints.maxHeight * 0.9;

            // 최소/최대 크기 제한
            final constrainedWidth = width.clamp(300.0, 600.0);
            final constrainedHeight = height.clamp(600.0, 1200.0);

            return Center(
              child: Container(
                constraints: BoxConstraints(
                  minWidth: constrainedWidth,
                  maxWidth: constrainedWidth,
                  minHeight: constrainedHeight,
                  maxHeight: constrainedHeight,
                ),
                child: ClipRect(
                  child: child ?? const SizedBox(), // null 안전성 추가
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // 페이지 목록
  final List<Widget> _pages = [const VVP(), const LVP(), const UIP()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YIM Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showSettingsDialog(context);
            },
          ),
        ],
      ),
      body: _pages[_currentIndex], // 현재 선택된 페이지만 표시
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Visual View',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List View'),
          BottomNavigationBarItem(
            icon: Icon(Icons.image),
            label: 'Upload Image',
          ),
        ],
      ),
    );
  }
}
