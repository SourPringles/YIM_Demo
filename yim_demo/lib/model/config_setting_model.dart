import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ConfigSetting {
  Map<String, dynamic> _configData = {};
  static const String _filename = 'server_config.ini';

  // 기본 설정값
  static final Map<String, dynamic> _defaultConfig = {
    'server': {
      'isLocalhost': true,
      'url': 'localhost',
      'port': '8000', // 문자열로 유지
    },
  };

  // 설정 로드
  Future<void> loadConfig() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_filename');

      if (await file.exists()) {
        final contents = await file.readAsString();
        _configData = _parseIni(contents);
      } else {
        _configData = Map<String, dynamic>.from(_defaultConfig);
        await saveConfig(); // 기본 설정을 파일로 저장
      }
    } catch (e) {
      //print('설정 로드 오류: $e');
      _configData = Map<String, dynamic>.from(_defaultConfig);
    }
  }

  // 깊은 복사를 위한 헬퍼 함수
  // ignore: unused_element
  Map<String, dynamic> _deepCopy(Map<String, dynamic> original) {
    Map<String, dynamic> result = {};
    original.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        result[key] = _deepCopy(value);
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  // 설정 저장
  Future<void> saveConfig() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_filename');

      final contents = _convertToIni(_configData);
      await file.writeAsString(contents);
    } catch (e) {
      //print('설정 저장 오류: $e');
    }
  }

  // INI 문자열 파싱
  Map<String, dynamic> _parseIni(String contents) {
    final result = <String, Map<String, dynamic>>{};
    Map<String, dynamic>? currentSection;

    for (var line in contents.split('\n')) {
      line = line.trim();

      if (line.isEmpty || line.startsWith(';')) {
        continue; // 빈 줄이나 주석 무시
      }

      if (line.startsWith('[') && line.endsWith(']')) {
        final sectionName = line.substring(1, line.length - 1);
        currentSection = {};
        result[sectionName] = currentSection;
      } else if (currentSection != null && line.contains('=')) {
        final parts = line.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join('=').trim();

          // 값의 타입 변환 (boolean만 변환하고 나머지는 문자열로 유지)
          if (value.toLowerCase() == 'true') {
            currentSection[key] = true;
          } else if (value.toLowerCase() == 'false') {
            currentSection[key] = false;
          } else {
            currentSection[key] = value; // 항상 문자열로 저장
          }
        }
      }
    }

    return result;
  }

  // Map을 INI 형식으로 변환
  String _convertToIni(Map<String, dynamic> config) {
    final buffer = StringBuffer();

    config.forEach((section, values) {
      buffer.writeln('[$section]');

      if (values is Map) {
        values.forEach((key, value) {
          buffer.writeln('$key=$value');
        });
      }

      buffer.writeln();
    });

    return buffer.toString();
  }

  // 서버 설정 가져오기 (타입 확인 및 변환 추가)
  bool get isLocalhost {
    final value = _configData['server']?['isLocalhost'];
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }

  String get url => _configData['server']?['url']?.toString() ?? 'localhost';

  String get port => _configData['server']?['port']?.toString() ?? '8000';

  // 서버 설정 저장하기
  Future<void> setServerConfig(
    bool isLocalhost,
    String url,
    String port,
  ) async {
    if (_configData['server'] == null) {
      _configData['server'] = <String, dynamic>{};
    }

    // 서버 섹션이 수정 불가능한 경우 새 맵 생성
    if (_configData['server'] is! Map<String, dynamic>) {
      final oldMap = _configData['server'] as Map;
      final newMap = <String, dynamic>{};
      oldMap.forEach((key, value) {
        newMap[key.toString()] = value;
      });
      _configData['server'] = newMap;
    }

    _configData['server']['isLocalhost'] = isLocalhost;
    _configData['server']['url'] = url;
    _configData['server']['port'] = port; // 문자열로 저장

    await saveConfig();
  }
}
