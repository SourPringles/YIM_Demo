import 'package:flutter/material.dart';

import '../service/visualviewpage_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MainPageService _mainPageService = MainPageService();
  List<Map<String, String>> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSettingsDialog(
        onClose: () {
          _fetchStorage();
        },
      );
    });
  }

  Future<void> _fetchStorage() async {
    final items = await _mainPageService.fetchStorage();
    setState(() {
      _items = items;
    });
  }

  void _showSettingsDialog({VoidCallback? onClose}) {
    showDialog(
      context: context,
      barrierDismissible: false, // 주변 여백 클릭으로 닫히지 않도록 설정
      builder: (BuildContext context) {
        return SettingsDialog(backendService: _backendService);
      },
    ).then((_) {
      if (onClose != null) onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MainPage'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchStorage),

          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              LocationPage(backendService: _backendService),
                    ),
                  );
                  _fetchInventory(); // 복귀 후 새로고침
                },
                child: const Text('물건 위치 보기'),
              ),
              ElevatedButton(
                onPressed: _uploadImage,
                child: const Text('이미지 업로드'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImage() async {
    final result = await _backendService.uploadImage(context);
    if (!mounted) return; // 위젯이 마운트되어 있는지 확인
    if (result) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미지 업로드 성공')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미지 업로드 실패')));
    }

    await _fetchInventory();
  }
}
