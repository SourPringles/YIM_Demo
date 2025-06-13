import 'package:flutter/material.dart';
import 'component_styles.dart';

class AppTheme {
  // Toss 스타일 테마 정의
  static ThemeData get tossTheme => ThemeData(
    // Toss 스타일 메인 컬러
    primaryColor: const Color(0xFF0064FF),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0064FF),
      primary: const Color(0xFF0064FF),
      secondary: const Color(0xFF3182F6),
      // ignore: deprecated_member_use
      background: Colors.white,
      surface: Colors.white,
    ),
    // 폰트
    fontFamily: 'Pretendard',
    // 텍스트 테마
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
        color: Color(0xFF191F28),
      ),
      headlineMedium: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Color(0xFF191F28),
      ),
      titleLarge: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: Color(0xFF191F28),
      ),
      bodyLarge: TextStyle(fontSize: 16.0, color: Color(0xFF191F28)),
      bodyMedium: TextStyle(fontSize: 14.0, color: Color(0xFF191F28)),
    ),
    // 버튼 테마
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ComponentStyles.elevatedButtonStyle(
        ThemeData(primaryColor: const Color(0xFF0064FF)),
      ),
    ),
    // 아웃라인 버튼 테마
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ComponentStyles.outlinedButtonStyle(
        ThemeData(primaryColor: const Color(0xFF0064FF)),
      ),
    ),
    // 카드 테마
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    // 앱 바 테마
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF191F28),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF191F28),
      ),
    ),
    // 다이얼로그 테마
    dialogTheme: DialogThemeData(shape: ComponentStyles.dialogShape),
  );
}
