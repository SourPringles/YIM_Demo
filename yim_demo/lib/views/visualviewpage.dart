import 'package:flutter/material.dart';

import '../service/visualviewpage_service.dart';
import 'view_utils.dart';

class VVP extends StatefulWidget {
  const VVP({super.key});

  @override
  State<VVP> createState() => _VVPState();
}

class _VVPState extends State<VVP> with SafeState<VVP> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text('Visual View Page'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStorage),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  // 내부 여백 설정
                  final horizontalPadding = 8.0; // 여백 줄임
                  final verticalPadding = 12.0;

                  // 화면 크기에 맞는 컨테이너 크기 계산
                  final maxWidth = constraints.maxWidth;
                  final maxHeight = constraints.maxHeight;

                  // 내부 컨텐츠 영역 계산
                  final contentWidth = maxWidth - (horizontalPadding * 2);
                  final contentHeight = maxHeight - (verticalPadding * 2);

                  // 최종 컨테이너 크기
                  final containerWidth = contentWidth;
                  final containerHeight = contentHeight;

                  return Center(
                    child: Container(
                      width: containerWidth,
                      height: containerHeight,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1), // 좌표 영역 시각화
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Stack(
                            children:
                                _items.map((item) {
                                  // 아이템 크기와 위치 계산 후 경계 제한
                                  // 아이템 크기는 비율에 맞게 조정
                                  double itemWidth =
                                      (double.tryParse(
                                            item["width"] ?? "100",
                                          ) ??
                                          100);
                                  double itemHeight =
                                      (double.tryParse(
                                            item["height"] ?? "35",
                                          ) ??
                                          35);

                                  // 원래 위치에 비율 적용
                                  double x =
                                      (double.tryParse(item["x"] ?? "0") ?? 0);
                                  double y =
                                      (double.tryParse(item["y"] ?? "0") ?? 0);

                                  // 경계 검사 (아이템이 컨테이너를 벗어나지 않도록)
                                  x = x.clamp(0, containerWidth - itemWidth);
                                  y = y.clamp(0, containerHeight - itemHeight);

                                  return Positioned(
                                    left: x,
                                    top: y,
                                    width: itemWidth,
                                    height: itemHeight,
                                    child: GestureDetector(
                                      onTap: () {
                                        DialogUtils.showItemDetails(
                                          context,
                                          item,
                                          onClose: _loadStorage,
                                        );
                                      },
                                      child: ItemBox(
                                        nickname: item["nickname"] ?? "Unknown",
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
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
      //width: 90, // 가로 90
      //height: 30, // 세로 30
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
