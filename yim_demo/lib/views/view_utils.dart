import 'package:flutter/material.dart';
import '../service/service_utils.dart';

class DialogUtils {
  static void showItemDetails(
    BuildContext context,
    Map<String, dynamic> item, {
    Function? onClose, // 콜백 함수 추가
  }) {
    // 닉네임 편집을 위한 컨트롤러
    final TextEditingController nicknameController = TextEditingController(
      text: item['nickname'] ?? 'Unknown',
    );
    // 상태 관리 변수
    bool isSaving = false;
    String? resultMessage;

    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                  _buildInfoRow('UUID', item['uuid'] ?? 'Unknown'),
                  _buildInfoRow('시간', item['timestamp'] ?? 'Unknown'),
                  _buildInfoRow('X 좌표', item['x']?.toString() ?? 'Unknown'),
                  _buildInfoRow('Y 좌표', item['y']?.toString() ?? 'Unknown'),

                  // 이미지 표시
                  if (item['uuid'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Image.network(
                        'http://localhost:5000/getImage/${item['uuid']}',
                        height: 150,
                        width: 150,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                Text('이미지를 불러올 수 없습니다'),
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
                    //if (onClose != null) onClose(); // 닫을 때 콜백 실행
                  },
                  child: Text('닫기'),
                ),
                // 저장 버튼
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
                                item['uuid'],
                                nicknameController.text,
                              );

                              // 원본 데이터 업데이트
                              item['nickname'] = nicknameController.text;

                              setState(() {
                                isSaving = false;
                                resultMessage = "저장 성공!";
                              });
                            } catch (e) {
                              setState(() {
                                isSaving = false;
                                resultMessage = "저장 실패: $e";
                              });
                            }
                            // 저장 완료 후
                            if (onClose != null) onClose(); // 저장 후에도 콜백 실행
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
          },
        );
      },
    ).then((_) => nicknameController.dispose());
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
