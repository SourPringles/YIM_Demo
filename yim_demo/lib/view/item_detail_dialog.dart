import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/common_data_provider.dart';
import '../model/compare_date_model.dart';

class ItemDetailDialog extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailDialog({super.key, required this.item});

  @override
  State<ItemDetailDialog> createState() => _ItemDetailDialogState();
}

class _ItemDetailDialogState extends State<ItemDetailDialog> {
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.item['nickname'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commonData = Provider.of<CommonDataProvider>(context, listen: false);
    final uuid = widget.item['uuid'] ?? '';

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

            // 이름 수정 가능한 필드
            Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    '이름:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child:
                      _isEditing
                          ? TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          )
                          : Text(_nameController.text),
                ),
                IconButton(
                  icon: Icon(_isEditing ? Icons.check : Icons.edit),
                  onPressed: () {
                    if (_isEditing) {
                      // 이름 변경 저장 로직 추가
                      // 서버에 변경 요청 또는 로컬 데이터 업데이트 구현 필요
                      try {
                        commonData.changeNickname(uuid, _nameController.text);
                      } catch (e) {
                        print('Error changing nickname: $e');
                      }
                      widget.item['nickname'] = _nameController.text;

                      // 데이터 갱신 (실제 구현에서는 서버 API 호출 필요)
                      // commonData.refreshData();

                      setState(() {
                        _isEditing = false;
                      });
                    } else {
                      setState(() {
                        _isEditing = true;
                      });
                    }
                  },
                ),
              ],
            ),

            // 나머지 기존 정보 표시
            _buildInfoRow('타임스탬프', widget.item['timestamp'] ?? '없음'),
            _buildInfoRow('마지막 접근', getDateDiffDays(widget.item['timestamp'])),
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
