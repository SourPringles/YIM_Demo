import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/common_data_provider.dart';
import '../model/compare_date_model.dart';
import '../theme/component_styles.dart'; // 테마 스타일 임포트

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
    final theme = Theme.of(context);

    return Dialog(
      shape: ComponentStyles.dialogShape, // 분리된 스타일 사용
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 및 닫기 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '아이템 세부 정보',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 16),

            // 이름 수정 가능한 필드
            Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    '이름:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  child:
                      _isEditing
                          ? TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: theme.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          )
                          : Text(
                            _nameController.text,
                            style: theme.textTheme.bodyLarge,
                          ),
                ),
                IconButton(
                  icon: Icon(
                    _isEditing ? Icons.check : Icons.edit,
                    color: theme.primaryColor,
                  ),
                  onPressed: () {
                    if (_isEditing) {
                      // 이름 변경 저장 로직 추가
                      try {
                        commonData.changeNickname(uuid, _nameController.text);
                      } catch (e) {
                        //print('Error changing nickname: $e');
                      }
                      widget.item['nickname'] = _nameController.text;

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
            const SizedBox(height: 24),

            // 아이템 이미지 - FutureBuilder 사용
            FutureBuilder<Image?>(
              future: commonData.httpConnection.getImage('getImage/$uuid'),
              builder: (context, snapshot) {
                return Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        snapshot.connectionState == ConnectionState.waiting
                            ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.primaryColor,
                                ),
                              ),
                            )
                            : snapshot.hasData && snapshot.data != null
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image(
                                image: snapshot.data!.image,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            )
                            : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '이미지를 불러올 수 없습니다',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // 확인 버튼
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('확인'),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[800])),
          ),
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
