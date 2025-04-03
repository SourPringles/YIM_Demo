import 'dart:io';
import 'package:ini/ini.dart';
import 'package:path_provider/path_provider.dart';

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  late Config _config;
  late String _configPath;
  bool _isInitialized = false;

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  Future<void> initialize({String fileName = 'settings.ini'}) async {
    if (_isInitialized) return;

    final directory = await getApplicationDocumentsDirectory();
    _configPath = '${directory.path}/$fileName';

    final configFile = File(_configPath);
    if (await configFile.exists()) {
      final content = await configFile.readAsString();
      _config = Config.fromString(content);
    } else {
      _config = Config();
      await save();
    }

    _isInitialized = true;
  }

  String? getString(String section, String key, {String? defaultValue}) {
    _ensureInitialized();
    return _config.get(section, key) ?? defaultValue;
  }

  int? getInt(String section, String key, {int? defaultValue}) {
    _ensureInitialized();
    final value = _config.get(section, key);
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  double? getDouble(String section, String key, {double? defaultValue}) {
    _ensureInitialized();
    final value = _config.get(section, key);
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  bool? getBool(String section, String key, {bool? defaultValue}) {
    _ensureInitialized();
    final value = _config.get(section, key)?.toLowerCase();
    if (value == null) return defaultValue;
    return value == 'true' || value == '1' || value == 'yes';
  }

  void setString(String section, String key, String value) {
    _ensureInitialized();
    _config.set(section, key, value);
  }

  void setInt(String section, String key, int value) {
    _ensureInitialized();
    _config.set(section, key, value.toString());
  }

  void setDouble(String section, String key, double value) {
    _ensureInitialized();
    _config.set(section, key, value.toString());
  }

  void setBool(String section, String key, bool value) {
    _ensureInitialized();
    _config.set(section, key, value ? 'true' : 'false');
  }

  Future<void> save() async {
    _ensureInitialized();
    final file = File(_configPath);
    await file.writeAsString(_config.toString());
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception('AppConfig가 초기화되지 않았습니다. initialize()를 먼저 호출하세요.');
    }
  }
}
