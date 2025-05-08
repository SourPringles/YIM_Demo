import 'dart:io';
import 'package:ini/ini.dart';
import 'package:path_provider/path_provider.dart';

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

  bool useLocalhost = true;
  String serverAddress = '192.168.0.1';
  String serverPort = '5000';

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
}
