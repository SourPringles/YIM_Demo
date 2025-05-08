import 'package:http/http.dart' as http;
import 'dart:convert';

import 'config_service.dart';

class LVPService {
  final ConfigService _configService = ConfigService();

  LVPService();

  // 서버에서 물건 데이터 가져오기
  Future<List<Map<String, dynamic>>> loadStorage() async {
    final baseUrl = await _configService.getBaseUrl();
    final url = Uri.parse("$baseUrl/getStorage");

    try {
      final response = await http.get(url);
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
}
