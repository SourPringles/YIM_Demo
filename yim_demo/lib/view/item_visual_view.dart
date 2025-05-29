// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../provider/common_data_provider.dart';
import '../model/compare_date_model.dart';
// ignore: unused_import
import '../theme/component_styles.dart'; // 테마 스타일 임포트
import 'item_detail_dialog.dart';

class ItemVisualView extends StatelessWidget {
  const ItemVisualView({super.key});

  @override
  Widget build(BuildContext context) {
    final commonData = Provider.of<CommonDataProvider>(context);
    final bgImage = commonData.getBackgroundImage();
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 타이틀 추가
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '냉장고 내부 보기',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  //const SizedBox(height: 8),
                  //Text(
                  //  '이미지 위에 배치된 아이템을 확인하세요',
                  //  style: theme.textTheme.bodyMedium?.copyWith(
                  //    color: Colors.grey[600],
                  //  ),
                  //),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 시각화 영역
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: commonData.getStorageItems(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.primaryColor,
                        ),
                      ),
                    );
                  }
                  final items = snapshot.data!;
                  // ignore: unnecessary_null_comparison
                  final isLoading = items.isEmpty && bgImage == null;

                  if (isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.primaryColor,
                        ),
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      double screenWidth = constraints.maxWidth;
                      double screenHeight = constraints.maxHeight;

                      return FutureBuilder<Image?>(
                        future: commonData.getBackgroundImage(),
                        builder: (context, bgImageSnapshot) {
                          if (!bgImageSnapshot.hasData ||
                              bgImageSnapshot.data == null) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '이미지를 불러올 수 없습니다',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            );
                          }
                          final bgImage = bgImageSnapshot.data!;

                          return FutureBuilder<Size>(
                            future: _getImageSize(bgImage.image),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.primaryColor,
                                    ),
                                  ),
                                );
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
                              double imageStartX =
                                  (screenWidth - displayWidth) / 2;
                              double imageStartY =
                                  (screenHeight - displayHeight) / 2;

                              return Stack(
                                children: [
                                  // 배경 이미지
                                  Positioned.fill(
                                    child: Container(
                                      margin: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image(
                                          image: bgImage.image,
                                          fit: BoxFit.contain,
                                          width: screenWidth,
                                          height: screenHeight,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // 아이템 박스들 - 이미지 기준으로 위치 조정
                                  ...items.map((item) {
                                    return Positioned(
                                      left:
                                          imageStartX +
                                          ((double.tryParse(item['x'] ?? '0') ??
                                                  0.0) *
                                              scale) -
                                          35,
                                      top:
                                          imageStartY +
                                          ((double.tryParse(item['y'] ?? '0') ??
                                                  0.0) *
                                              scale) -
                                          10,
                                      child: ItemBox(
                                        nickname: item['nickname'] ?? '',
                                        timestmap:
                                            item['timestamp'] ??
                                            "${DateTime.now()}",
                                        itemData: item, // 전체 아이템 데이터 전달
                                      ),
                                    );
                                  }),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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

// 아이템박스 위젯 개선
class ItemBox extends StatelessWidget {
  final String nickname;
  final String timestmap;
  final Map<String, dynamic> itemData;

  const ItemBox({
    super.key,
    required this.nickname,
    required this.timestmap,
    required this.itemData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        // 클릭 시 다이얼로그 표시
        showItemDetailDialog(context, itemData);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              nickname,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              getDateDiffDays(timestmap),
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
