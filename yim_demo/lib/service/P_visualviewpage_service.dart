import 'package:flutter/material.dart';
import 'dart:convert';

import 'config_service.dart';
import 'http_service.dart';

class VVPService {
  final ConfigService _configService = ConfigService();
  final HttpService _httpService = HttpService();

  VVPService();

  // 서버에서 물건 데이터 가져오기
  Future<List<Map<String, dynamic>>> loadStorage() async {
    try {
      final response = await _httpService.get('getStorage');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // JSON 데이터 처리 (리스트 순회)
        return data.map((itemData) {
          final item = itemData as Map<String, dynamic>;
          return {
            "uuid": item["uuid"]?.toString() ?? "Unknown",
            "nickname": item["nickname"]?.toString() ?? "Unknown",
            "timestamp": item["timestamp"]?.toString() ?? "Unknown",
            "x": item["x"]?.toString() ?? "Unknown",
            "y": item["y"]?.toString() ?? "Unknown",
          };
        }).toList();
      } else {
        print('Failed to fetch storage: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // 오류 발생 시 타입 캐스팅 오류 등을 포함하여 출력
      print('Error fetching storage: $e');
      return [];
    }
  }

  Future<Image> loadImage() async {
    try {
      for (int i = 0; i < 3; i++) {
        try {
          final bytes = await _httpService.getBytes('getBackground');
          return Image.memory(bytes);
        } catch (e) {
          if (i == 2) rethrow;
          await Future.delayed(Duration(seconds: 1));
        }
      }
      throw Exception('Failed after retries');
    } catch (e) {
      print('Error fetching image: $e');
      return Image.asset('assets/images/placeholder.png');
    }
  }
}
