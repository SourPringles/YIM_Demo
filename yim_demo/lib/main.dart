import 'package:flutter/material.dart';

import 'views/visualviewpage.dart';
import 'views/listviewpage.dart';
import 'views/uploadimagepage.dart';

import 'views/settingspage.dart';

void main() {
  runApp(const MainApp());
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
            // 최소 너비 300px, 최대 너비 600px로 제한
            final width =
                constraints.maxWidth > 600
                    ? 600.0
                    : constraints.maxWidth < 300
                    ? 300.0
                    : constraints.maxWidth;
            final height = width * 2; // 1:2 비율 유지

            return Center(
              child: Container(
                constraints: BoxConstraints(
                  minWidth: width,
                  minHeight: height,
                  maxWidth: width,
                  maxHeight: height,
                ),
                child: ClipRect(child: child),
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
