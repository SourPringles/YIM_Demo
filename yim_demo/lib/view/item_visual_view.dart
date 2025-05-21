import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../provider/common_data_provider.dart';
import '../model/compare_date_model.dart';
import 'item_detail_dialog.dart';

class ItemVisualView extends StatelessWidget {
  const ItemVisualView({super.key});

  @override
  Widget build(BuildContext context) {
    final commonData = Provider.of<CommonDataProvider>(context);
    final items = commonData.getStorageItems();
    final bgImage = commonData.getBackgroundImage();
    final isLoading = items.isEmpty && bgImage == null;

    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;
                  double screenHeight = constraints.maxHeight;

                  if (bgImage == null) {
                    return Center(child: Text('이미지를 불러올 수 없습니다.'));
                  }

                  return FutureBuilder<Size>(
                    future: _getImageSize(bgImage.image),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // 이미지의 실제 크기 사용
                      double originalWidth = snapshot.data!.width;
                      double originalHeight = snapshot.data!.height;

                      // 화면에 표시될 이미지의 실제 크기 계산 (BoxFit.contain 적용 시)
                      double displayWidth = screenWidth;
                      double displayHeight = screenHeight;
                      double scale = 1.0;

                      // 이미지 비율에 따라 실제 표시 크기 계산
                      if (originalWidth / originalHeight >
                          screenWidth / screenHeight) {
                        // 이미지가 화면보다 가로로 더 긴 경우
                        scale = screenWidth / originalWidth;
                        displayWidth = screenWidth;
                        displayHeight = originalHeight * scale;
                      } else {
                        // 이미지가 화면보다 세로로 더 긴 경우
                        scale = screenHeight / originalHeight;
                        displayHeight = screenHeight;
                        displayWidth = originalWidth * scale;
                      }

                      // 이미지가 중앙에 위치할 때 시작 좌표 계산
                      double imageStartX = (screenWidth - displayWidth) / 2;
                      double imageStartY = (screenHeight - displayHeight) / 2;

                      return Stack(
                        children: [
                          // 배경 이미지
                          Positioned.fill(
                            child: Image(
                              image: bgImage.image,
                              fit: BoxFit.contain,
                              width: screenWidth,
                              height: screenHeight,
                            ),
                          ),

                          // 아이템 박스들 - 이미지 기준으로 위치 조정
                          ...items.map((item) {
                            // 콘솔에 item 출력
                            // print("Item data: ${item['timestamp']}");

                            return Positioned(
                              left:
                                  imageStartX +
                                  ((double.tryParse(item['x'] ?? '0') ?? 0.0) *
                                      scale) -
                                  30,
                              top:
                                  imageStartY +
                                  ((double.tryParse(item['y'] ?? '0') ?? 0.0) *
                                      scale) -
                                  10,
                              child: ItemBox(
                                nickname: item['nickname'] ?? '',
                                timestmap:
                                    item['timestamp'] ?? "${DateTime.now()}",
                                itemData: item, // 전체 아이템 데이터 전달
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  );
                },
              ),
    );
  }

  Future<Size> _getImageSize(ImageProvider imageProvider) {
    final completer = Completer<Size>();

    imageProvider
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((ImageInfo info, bool _) {
            completer.complete(
              Size(info.image.width.toDouble(), info.image.height.toDouble()),
            );
          }),
        );

    return completer.future;
  }
}

// 아이템박스 위젯 WIP
class ItemBox extends StatelessWidget {
  final String nickname;
  final String timestmap;
  final Map<String, dynamic> itemData; // 추가: 전체 아이템 데이터

  const ItemBox({
    super.key,
    required this.nickname,
    required this.timestmap,
    required this.itemData, // 아이템 데이터 매개변수 추가
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 클릭 시 다이얼로그 표시
        showItemDetailDialog(context, itemData);
      },
      child: Container(
        //width: 90, // 가로 90
        //height: 30, // 세로 30
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle, // 사각형 형태
          border: Border.all(
            color: Colors.black, // 테두리 색상
            width: 1, // 테두리 두께
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              nickname,
              style: const TextStyle(color: Colors.black, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            Text(
              getDateDiffDays(timestmap),
              style: const TextStyle(color: Colors.black, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
