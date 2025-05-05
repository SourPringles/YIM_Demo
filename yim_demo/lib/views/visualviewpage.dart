import 'package:flutter/material.dart';

import '../service/visualviewpage_service.dart';

class VisualViewPage extends StatefulWidget {
  const VisualViewPage({super.key});

  @override
  State<VisualViewPage> createState() => _MainPageState();
}

class _MainPageState extends State<VisualViewPage> {
  final MainPageService _mainPageService = MainPageService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchStorage() async {
    final items = await _mainPageService.fetchStorage();
    setState(() {
      _items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MainPage'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchStorage),

          IconButton(icon: const Icon(Icons.settings), onPressed: () => asdf()),
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
}
