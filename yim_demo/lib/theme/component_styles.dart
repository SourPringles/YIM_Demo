import 'package:flutter/material.dart';

/// UI 컴포넌트별 스타일을 정의하는 클래스
class ComponentStyles {
  static final Color tossBlue = Color(0xFF0064FF);

  // 컨테이너 스타일
  static BoxDecoration imageContainerDecoration = BoxDecoration(
    color: Colors.grey[100],
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey[300]!),
  );

  // 아웃라인 버튼 스타일 (ButtonStyle 타입으로 수정)
  static ButtonStyle outlinedButtonStyle(ThemeData theme) {
    return OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      side: BorderSide(color: theme.primaryColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // 기본 버튼 스타일
  static ButtonStyle elevatedButtonStyle(ThemeData theme) {
    return ElevatedButton.styleFrom(
      backgroundColor: theme.primaryColor,
      foregroundColor: Colors.white,
      disabledBackgroundColor: Colors.grey[300],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      minimumSize: const Size(double.infinity, 56),
    );
  }

  // 성공 메시지 컨테이너 스타일
  static BoxDecoration successMessageDecoration = BoxDecoration(
    color: Colors.green[50],
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.green[200]!),
  );

  // 에러 메시지 컨테이너 스타일
  static BoxDecoration errorMessageDecoration = BoxDecoration(
    color: Colors.red[50],
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.red[200]!),
  );

  // 다이얼로그 스타일
  static ShapeBorder dialogShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );
}
