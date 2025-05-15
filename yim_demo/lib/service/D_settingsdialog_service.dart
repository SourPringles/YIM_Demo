import 'config_service.dart';
import 'http_service.dart';
import 'dart:async';

class SPService {
  final ConfigService _configService = ConfigService();
  final HttpService _httpService = HttpService();

  SPService();

  // 서버 설정을 가져오는 메서드
  Future<Map<String, dynamic>> getServerSettings() async {
    final settings = await _configService.getServerSettings();
    return settings;
  }

  // testConnection 메서드
  Future<bool> testConnection({
    bool? useLocalhost,
    String? serverAddress,
    String? serverPort,
  }) async {
    final settings = await getServerSettings();

    final host =
        useLocalhost ?? settings['useLocalhost']
            ? 'localhost'
            : (serverAddress ?? settings['serverAddress']);
    final port = serverPort ?? settings['serverPort'];

    // 테스트용 임시 baseUrl 구성
    final testUrl = 'http://$host:$port';

    try {
      final response = await _httpService
          .get('', baseUrl: testUrl) // baseUrl 파라미터 추가
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              throw TimeoutException('Connection timed out');
            },
          );
      return response.statusCode == 200;
    } catch (e) {
      if (e is TimeoutException) {
        throw 'IP 주소를 다시 확인해주세요. 서버 응답이 없습니다.';
      }
      return false;
    }
  }

  // saveServerSettings 메서드
  Future<bool> saveServerSettings({
    required bool useLocalhost,
    required String serverAddress,
    required String serverPort,
  }) async {
    return await _configService.saveServerSettings(
      useLocalhost: useLocalhost,
      serverAddress: serverAddress,
      serverPort: serverPort,
    );
  }
}
