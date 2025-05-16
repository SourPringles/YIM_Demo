import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/commonDataProvider.dart';
import 'testView.dart';
import 'itemVisualView.dart';
import 'itemListView.dart';
import 'imageUploadView.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;
  bool _showTestViewer = false; // TestViewer 표시 여부를 결정하는 변수

  // 페이지 목록
  final List<Widget> _pages = [
    const ItemVisualView(),
    const ItemListView(),
    const ImageUploadView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YIM Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<CommonDataProvider>(
                context,
                listen: false,
              ).refreshData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              setState(() {
                _showTestViewer = !_showTestViewer; // 상태 토글
              });
            },
          ),
        ],
      ),
      // 조건부로 body 내용 결정
      body: _showTestViewer ? const TestView() : _pages[_currentIndex],
      bottomNavigationBar:
          _showTestViewer
              ? null // TestViewer 표시 중일 때는 바텀 네비게이션 바 숨김(선택사항)
              : BottomNavigationBar(
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
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list),
                    label: 'List View',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.image),
                    label: 'Upload Image',
                  ),
                ],
              ),
    );
  }
}
