import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/common_data_provider.dart';
import 'item_detail_dialog.dart'; // 다이얼로그 import 추가

class ItemListView extends StatelessWidget {
  const ItemListView({super.key});

  @override
  Widget build(BuildContext context) {
    final commonData = Provider.of<CommonDataProvider>(context);
    final items = commonData.getStorageItems();
    final isLoading = items.isEmpty;

    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item['nickname'] ?? '이름 없음'),
                    subtitle: Text(
                      '좌표: (${item['x'] ?? 0}, ${item['y'] ?? 0})',
                    ),
                    onTap: () {
                      // 아이템 상세 다이얼로그 표시
                      showItemDetailDialog(context, item);
                    },
                  );
                },
              ),
    );
  }
}
