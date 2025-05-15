import 'config_service.dart';
import 'http_service.dart';

class ServiceUtils {
  static final ConfigService _configService = ConfigService();
  static final HttpService _httpService = HttpService();

  // 서버에 닉네임 업데이트 요청
  static Future<void> updateNickname(String uuid, String nickname) async {
    final response = await _httpService.post('rename/$uuid/$nickname');
    if (response.statusCode != 200) {
      throw Exception('Failed to update: ${response.statusCode}');
    }
  }

  // 이미지 URL 가져오기
  static Future<String> getImageUrl(String uuid) async {
    final baseUrl = await _configService.getBaseUrl();
    return '$baseUrl/getImage/$uuid';
  }
}
