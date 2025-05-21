import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/common_data_provider.dart';
import '../model/compare_date_model.dart';

class ItemDetailDialog extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemDetailDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final commonData = Provider.of<CommonDataProvider>(context, listen: false);
    final uuid = item['uuid'] ?? '';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 및 닫기 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '아이템 세부 정보',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 10),

            // 아이템 정보 표시
            //_buildInfoRow('UUID', item['uuid'] ?? '없음'),
            _buildInfoRow('이름', item['nickname'] ?? '없음'),
            _buildInfoRow('타임스탬프', item['timestamp'] ?? '없음'),
            _buildInfoRow('마지막 접근', getDateDiffDays(item['timestamp'])),
            //_buildInfoRow('X 좌표', item['x'] ?? '없음'),
            //_buildInfoRow('Y 좌표', item['y'] ?? '없음'),
            const SizedBox(height: 20),

            // 아이템 이미지 - FutureBuilder 사용
            FutureBuilder<Image?>(
              future: commonData.httpConnection.getImage('getImage/$uuid'),
              builder: (context, snapshot) {
                return Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        snapshot.connectionState == ConnectionState.waiting
                            ? const Center(child: CircularProgressIndicator())
                            : snapshot.hasData && snapshot.data != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image(
                                image: snapshot.data!.image,
                                fit: BoxFit.contain, // 이미지 비율을 유지하면서 컨테이너에 맞춤
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                            : const Center(child: Text('이미지를 불러올 수 없습니다.')),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 확인 버튼
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text('확인'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// 다이얼로그를 표시하는 함수
void showItemDetailDialog(BuildContext context, Map<String, dynamic> item) {
  showDialog(
    context: context,
    builder: (context) => ItemDetailDialog(item: item),
  );
}
