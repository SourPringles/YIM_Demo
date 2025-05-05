import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String USE_LOCALHOST_KEY = 'use_localhost';
  static const String SERVER_ADDRESS_KEY = 'server_address';
  static const String SERVER_PORT_KEY = 'server_port';

  // 서버 설정 가져오기
  Future<Map<String, dynamic>> getServerSettings() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'useLocalhost': prefs.getBool(USE_LOCALHOST_KEY) ?? true,
      'serverAddress': prefs.getString(SERVER_ADDRESS_KEY) ?? '192.168.0.1',
      'serverPort': prefs.getString(SERVER_PORT_KEY) ?? '5000',
    };
  }

  // 서버 설정 저장하기
  Future<bool> saveServerSettings({
    required bool useLocalhost,
    required String serverAddress,
    required String serverPort,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(USE_LOCALHOST_KEY, useLocalhost);
    await prefs.setString(SERVER_ADDRESS_KEY, serverAddress);
    await prefs.setString(SERVER_PORT_KEY, serverPort);

    return true;
  }

  // 서버 연결 테스트
  Future<bool> testServerConnection({
    required bool useLocalhost,
    required String serverAddress,
    required String serverPort,
  }) async {
    final host = useLocalhost ? 'localhost' : serverAddress;
    final url = Uri.parse('http://$host:$serverPort');

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
}
