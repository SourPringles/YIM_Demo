import 'dart:io';
import 'dart:convert';
import 'config_service.dart';
import 'http_service.dart';

class UIPService {
  final ConfigService _configService = ConfigService();
  final HttpService _httpService = HttpService();

  // 이미지 업로드 함수
  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    try {
      final response = await _httpService.postFile('updateStorage', imageFile);
      final responseBody = await response.stream.bytesToString();

      // 응답 처리
      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
