import 'package:http/http.dart' as http;

import 'config_service.dart';

class ServiceUtils {
  static final ConfigService _configService = ConfigService();

  // 서버에 닉네임 업데이트 요청
  static Future<void> updateNickname(String uuid, String nickname) async {
    final baseUrl = await _configService.getBaseUrl();

    // 엔드포인트 형식: '/rename/uid/변경닉네임'
    final response = await http.post(
      Uri.parse('$baseUrl/rename/$uuid/$nickname'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update: ${response.statusCode}');
    }
  }
}
