import 'package:flutter/material.dart';

import '../service/visualviewpage_service.dart';

class VVP extends StatefulWidget {
  const VVP({super.key});

  @override
  State<VVP> createState() => _VVPState();
}

class _VVPState extends State<VVP> {
  final VVPService _vvpService = VVPService();

  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    final items = await _vvpService.loadStorage();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('아이템 정보'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('이름', item['nickname'] ?? 'Unknown'),
              _buildInfoRow('UUID', item['uuid'] ?? 'Unknown'),
              _buildInfoRow('시간', item['timestamp'] ?? 'Unknown'),
              _buildInfoRow('X 좌표', item['x']?.toString() ?? 'Unknown'),
              _buildInfoRow('Y 좌표', item['y']?.toString() ?? 'Unknown'),
              // 이미지가 있는 경우 이미지 표시
              if (item['uuid'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Image.network(
                    'http://localhost:5000/getImage?uuid=${item['uuid']}',
                    height: 150,
                    width: 150,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) => Text('이미지를 불러올 수 없습니다'),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStorage),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  final containerWidth = 600.0;
                  final containerHeight = 1000.0;

                  return SizedBox(
                    width: containerWidth,
                    height: containerHeight,
                    //color: Colors.grey.shade200, // 경계 시각화
                    child: Stack(
                      children:
                          _items.map((item) {
                            // 아이템의 크기 (예상)
                            const itemWidth = 100.0;
                            const itemHeight = 35.0;

                            // 원래 위치 가져오기
                            double x = double.tryParse(item["x"] ?? "0") ?? 0;
                            double y = double.tryParse(item["y"] ?? "0") ?? 0;

                            // 경계 검사 및 위치 제한
                            x = x.clamp(0, containerWidth - itemWidth);
                            y = y.clamp(0, containerHeight - itemHeight);

                            return Positioned(
                              left: x,
                              top: y,
                              child: GestureDetector(
                                onTap: () {
                                  _showItemDetails(item);
                                },
                                child: ItemBox(
                                  nickname: item["nickname"] ?? "Unknown",
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  );
                },
              ),
    );
  }
}

// 아이템박스 위젯
class ItemBox extends StatelessWidget {
  final String nickname;

  const ItemBox({super.key, required this.nickname});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90, // 가로 90
      height: 30, // 세로 30
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.rectangle, // 사각형 형태
        border: Border.all(
          color: Colors.black, // 테두리 색상
          width: 1, // 테두리 두께
        ),
      ),
      child: Center(
        child: Text(
          nickname,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12, // 텍스트 크기 조정
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
