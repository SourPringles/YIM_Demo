// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/common_data_provider.dart';
// ignore: unused_import
import '../theme/component_styles.dart'; // 테마 스타일 임포트
import 'test_view.dart';
import 'item_visual_view.dart';
import 'item_list_view.dart';
import 'image_upload_view.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('YIM Demo'),
        elevation: 0, // 그림자 제거
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
      body: Container(
        decoration: BoxDecoration(
          // 테두리 스타일 업데이트
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.2),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.all(4.0),
        child: _showTestViewer ? const TestView() : _pages[_currentIndex],
      ),
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
                selectedItemColor: theme.primaryColor, // 선택된 아이템 색상
                unselectedItemColor: Colors.grey[600], // 선택되지 않은 아이템 색상
                items: const [
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
