// service/server_config_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:ini/ini.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ConfigService {
  // 싱글턴 패턴 구현
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  Config? _config;
  String? _configPath;
  String? _cachedBaseUrl;

  final String _fileName = 'server_settings.ini';
  final String _serverSection = 'Server';

  // 기본 서버 설정값
  final Map<String, dynamic> _defaultServerSettings = {
    'useLocalhost': 'true',
    'address': '127.0.0.1',
    'port': '5000',
  };

  // 설정 파일 경로 가져오기
  Future<String> get _filePath async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_fileName';
  }

  // 설정 로드
  Future<void> loadConfig() async {
    if (_config != null) return;

    final directory = await getApplicationDocumentsDirectory();
    _configPath = '${directory.path}/$_fileName';

    // 파일 존재 여부 확인
    final file = File(_configPath!);
    if (!await file.exists()) {
      // 파일이 없으면 기본 설정으로 새로 생성
      await _createDefaultConfig(file);
    }

    // 설정 파일 로드
    final content = await file.readAsString();
    _config = Config.fromString(content);
  }

  // 기본 설정으로 ini 파일 생성
  Future<void> _createDefaultConfig(File file) async {
    final newConfig = Config();

    // 서버 섹션 생성
    newConfig.addSection(_serverSection);

    // 기본값 설정
    _defaultServerSettings.forEach((key, value) {
      newConfig.set(_serverSection, key, value);
    });

    // 파일에 저장
    await file.writeAsString(newConfig.toString());
    print('Created default configuration file at ${file.path}');
  }

  // 설정 저장
  Future<void> saveConfig() async {
    if (_config == null || _configPath == null) {
      await loadConfig();
    }

    final file = File(_configPath!);
    await file.writeAsString(_config.toString());

    // URL 캐시 초기화
    _cachedBaseUrl = null;
  }

  // 서버 설정 가져오기
  Future<Map<String, dynamic>> getServerSettings() async {
    await loadConfig();

    return {
      'useLocalhost': _config!.get(_serverSection, 'useLocalhost') == 'true',
      'serverAddress': _config!.get(_serverSection, 'address'),
      'serverPort': _config!.get(_serverSection, 'port'),
    };
  }

  // 서버 설정 저장하기
  Future<bool> saveServerSettings({
    required bool useLocalhost,
    required String serverAddress,
    required String serverPort,
  }) async {
    await loadConfig();

    _config!.set(_serverSection, 'useLocalhost', useLocalhost.toString());
    _config!.set(_serverSection, 'address', serverAddress);
    _config!.set(_serverSection, 'port', serverPort);

    await saveConfig();

    // 캐시된 URL 초기화
    _cachedBaseUrl = null;

    return true;
  }

  // 서버 URL 가져오기 (캐싱 사용)
  Future<String> getBaseUrl() async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;

    final settings = await getServerSettings();
    final useLocalhost = settings['useLocalhost'];
    final address = settings['serverAddress'];
    final port = settings['serverPort'];

    _cachedBaseUrl =
        useLocalhost ? 'http://localhost:$port' : 'http://$address:$port';
    return _cachedBaseUrl!;
  }

  // 서버 연결 테스트
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

  // GET 요청 수행
  Future<dynamic> getData(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    final baseUrl = await getBaseUrl();
    final uri = Uri.parse(
      '$baseUrl/$endpoint',
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('데이터 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // POST 요청 수행
  Future<dynamic> postData(String endpoint, {dynamic data}) async {
    final baseUrl = await getBaseUrl();
    final uri = Uri.parse('$baseUrl/$endpoint');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('데이터 전송 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // PUT 요청 수행
  Future<dynamic> putData(String endpoint, {dynamic data}) async {
    final baseUrl = await getBaseUrl();
    final uri = Uri.parse('$baseUrl/$endpoint');

    try {
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('데이터 업데이트 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // DELETE 요청 수행
  Future<bool> deleteData(String endpoint) async {
    final baseUrl = await getBaseUrl();
    final uri = Uri.parse('$baseUrl/$endpoint');

    try {
      final response = await http.delete(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
}
