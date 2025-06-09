import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class HttpConnection {
  bool _isLocalhost = true;
  String _url = '192.168.0.1';
  String _port = '5000';

  bool get isLocalhost => _isLocalhost;
  String get url => _url;
  String get port => _port;

  HttpConnection();

  void setLocalhost(bool isLocalhost) {
    _isLocalhost = isLocalhost;
  }

  void setUrl(String url) {
    _url = url;
  }

  void setPort(String port) {
    _port = port;
  }

  String getBaseUrl() {
    if (_isLocalhost) {
      return 'http://localhost:$_port';
    } else {
      return 'http://$url:$port';
    }
  }

  Future<http.Response> get(String endpoint) async {
    final url = getBaseUrl();
    return await http
        .get(Uri.parse('$url/$endpoint'))
        .timeout(const Duration(seconds: 60 * 5));
  }

  Future<http.StreamedResponse> postFile(String endpoint, File file) async {
    final baseUrl = getBaseUrl();
    final url = Uri.parse('$baseUrl/$endpoint');

    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('source', file.path));

    return await request.send().timeout(const Duration(seconds: 60 * 5));
  }

  Future<List<Map<String, dynamic>>> getStorage() async {
    try {
      final response = await get('getStorage');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // JSON 데이터 처리 (리스트 순회)
        return data.map((itemData) {
          final item = itemData as Map<String, dynamic>;
          return {
            "uuid": item["uuid"]?.toString() ?? "Unknown",
            "nickname": item["nickname"]?.toString() ?? "Unknown",
            "timestamp": item["timestamp"]?.toString() ?? "Unknown",
            "x": item["x"]?.toString() ?? "Unknown",
            "y": item["y"]?.toString() ?? "Unknown",
          };
        }).toList();
      } else {
        //print('Failed to fetch storage: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // 오류 발생 시 타입 캐스팅 오류 등을 포함하여 출력
      //print('Error fetching storage: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTemp() async {
    try {
      final response = await get('getTemp');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // JSON 데이터 처리 (리스트 순회)
        return data.map((itemData) {
          final item = itemData as Map<String, dynamic>;
          return {
            "uuid": item["uuid"]?.toString() ?? "Unknown",
            "nickname": item["nickname"]?.toString() ?? "Unknown",
            "timestamp": item["timestamp"]?.toString() ?? "Unknown",
          };
        }).toList();
      } else {
        //print('Failed to fetch Temp: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // 오류 발생 시 타입 캐스팅 오류 등을 포함하여 출력
      //print('Error fetching storage: $e');
      return [];
    }
  }

  Future<Image?> getImage(String endpoint) async {
    try {
      final url = getBaseUrl();
      final response = await http.get(Uri.parse('$url/$endpoint'));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        return Image.memory(bytes);
      } else {
        //print('Failed to fetch image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      //print('Error fetching image: $e');
      return null;
    }
  }
}
