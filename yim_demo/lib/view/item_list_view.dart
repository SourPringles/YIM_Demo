import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/common_data_provider.dart';
import 'item_detail_dialog.dart'; // 다이얼로그 import 추가

class ItemListView extends StatelessWidget {
  const ItemListView({super.key});

  @override
  Widget build(BuildContext context) {
    final commonData = Provider.of<CommonDataProvider>(context);

    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: commonData.getStorageItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('아이템이 없습니다.'));
          } else {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item['nickname'] ?? '이름 없음'),
                  subtitle: Text('좌표: (${item['x'] ?? 0}, ${item['y'] ?? 0})'),
                  onTap: () {
                    // 아이템 상세 다이얼로그 표시
                    showItemDetailDialog(context, item);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
