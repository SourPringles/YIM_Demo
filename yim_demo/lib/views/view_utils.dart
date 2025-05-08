import 'package:flutter/material.dart';

import '../service/service_utils.dart';

class ItemDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onSaved; // 저장 성공시 호출될 콜백

  const ItemDetailsDialog({required this.item, this.onSaved, super.key});

  @override
  State<ItemDetailsDialog> createState() => _ItemDetailsDialogState();
}

class _ItemDetailsDialogState extends State<ItemDetailsDialog> {
  late final TextEditingController nicknameController;
  bool isSaving = false;
  String? resultMessage;

  @override
  void initState() {
    super.initState();
    nicknameController = TextEditingController(
      text: widget.item['nickname'] ?? 'Unknown',
    );
  }

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('아이템 정보'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 닉네임 텍스트필드 추가
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: TextField(
              controller: nicknameController,
              decoration: InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          _buildInfoRow('UUID', widget.item['uuid'] ?? 'Unknown'),
          _buildInfoRow('시간', widget.item['timestamp'] ?? 'Unknown'),
          _buildInfoRow('X 좌표', widget.item['x']?.toString() ?? 'Unknown'),
          _buildInfoRow('Y 좌표', widget.item['y']?.toString() ?? 'Unknown'),

          // 이미지 표시
          if (widget.item['uuid'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Image.network(
                'http://localhost:5000/getImage/${widget.item['uuid']}',
                height: 150,
                width: 150,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) => Text('이미지를 불러올 수 없습니다'),
              ),
            ),

          // 저장 결과 메시지
          if (resultMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Container(
                padding: EdgeInsets.all(8),
                color:
                    resultMessage!.contains("성공")
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                child: Text(
                  resultMessage!,
                  style: TextStyle(
                    color:
                        resultMessage!.contains("성공")
                            ? Colors.green.shade900
                            : Colors.red.shade900,
                  ),
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('닫기'),
        ),
        ElevatedButton(
          onPressed:
              isSaving
                  ? null
                  : () async {
                    setState(() {
                      isSaving = true;
                      resultMessage = null;
                    });

                    try {
                      await ServiceUtils.updateNickname(
                        widget.item['uuid'],
                        nicknameController.text,
                      );

                      widget.item['nickname'] = nicknameController.text;

                      setState(() {
                        isSaving = false;
                        resultMessage = "저장 성공!";
                      });

                      // 저장 성공시에만 콜백 실행
                      if (widget.onSaved != null) {
                        widget.onSaved!();
                      }
                    } catch (e) {
                      setState(() {
                        isSaving = false;
                        resultMessage = "저장 실패: $e";
                      });
                    }
                  },
          child:
              isSaving
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text('저장'),
        ),
      ],
    );
  }

  // 정보 행 위젯
  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class DialogUtils {
  static void showItemDetails(
    BuildContext context,
    Map<String, dynamic> item, {
    VoidCallback? onSaved, // 저장 성공시 호출될 콜백
  }) {
    showDialog(
      context: context,
      builder: (context) => ItemDetailsDialog(item: item, onSaved: onSaved),
    );
  }
}

// 위젯 마운트 여부 체크
mixin SafeState<T extends StatefulWidget> on State<T> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
