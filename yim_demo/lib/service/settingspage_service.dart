import 'package:http/http.dart' as http;

import 'config_service.dart';

class SPService {
  final ConfigService _configService = ConfigService();

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
    final url = Uri.parse('http://$host:$port');

    try {
      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => http.Response('Timeout', 408),
          );

      return response.statusCode == 200;
    } catch (e) {
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
