import 'package:flutter/material.dart';

import '../service/P_visualviewpage_service.dart';
import 'D_itemdetaildialog.dart';

class VVP extends StatefulWidget {
  const VVP({super.key});

  @override
  State<VVP> createState() => _VVPState();
}

class _VVPState extends State<VVP> with SafeState<VVP> {
  final VVPService _vvpService = VVPService();

  List<dynamic> _items = [];
  Image? _bgImage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    // 상태 업데이트가 완료될 때까지 기다림
    await Future(
      () => setState(() {
        _isLoading = true;
        _items = [];
        _bgImage = null;
      }),
    );

    final items = await _vvpService.loadStorage();
    final bgImage = await _vvpService.loadImage();

    setState(() {
      _items = items;
      _bgImage = bgImage;
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
                  // 이미지 실제 크기 상수 정의
                  const IMAGE_WIDTH = 300.0; // 실제 이미지 크기로 수정
                  const IMAGE_HEIGHT = 600.0;
                  const IMAGE_ASPECT_RATIO = IMAGE_WIDTH / IMAGE_HEIGHT;

                  // 화면 크기에 맞는 컨테이너 크기 계산
                  double availableWidth = constraints.maxWidth;
                  double availableHeight = constraints.maxHeight;

                  // 컨테이너 크기 계산
                  double containerWidth = availableWidth;
                  double containerHeight = availableHeight;

                  // 컨테이너 비율 조정
                  if (containerWidth / containerHeight > IMAGE_ASPECT_RATIO) {
                    containerWidth = containerHeight * IMAGE_ASPECT_RATIO;
                  } else {
                    containerHeight = containerWidth / IMAGE_ASPECT_RATIO;
                  }

                  // 이미지 크기는 컨테이너와 동일하게 설정
                  double imageWidth = containerWidth;
                  double imageHeight = containerHeight;

                  return Center(
                    child: SizedBox(
                      // Container 대신 SizedBox 사용
                      width: containerWidth,
                      height: containerHeight,
                      child: Stack(
                        fit: StackFit.expand, // Stack이 전체 공간을 사용하도록 설정
                        children: [
                          // 배경 이미지
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                    _bgImage?.image ??
                                    AssetImage('assets/default_bg.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          // 아이템 박스들
                          ..._items.map((item) {
                            // 좌표 계산 단순화
                            double x =
                                (double.tryParse(item["x"] ?? "0") ?? 0) /
                                    IMAGE_WIDTH *
                                    containerWidth -
                                50;
                            double y =
                                (double.tryParse(item["y"] ?? "0") ?? 0) /
                                    IMAGE_HEIGHT *
                                    containerHeight -
                                10;

                            return Positioned(
                              left: x,
                              top: y,
                              child: ItemBox(
                                nickname: item["nickname"] ?? "Unknown",
                              ),
                            );
                          }).toList(),
                        ],
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
