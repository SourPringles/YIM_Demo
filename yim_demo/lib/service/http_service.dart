import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'config_service.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;

  final http.Client _client = http.Client();
  final ConfigService _configService = ConfigService();

  HttpService._internal();

  Future<String> getBaseUrl() async {
    return await _configService.getBaseUrl();
  }

  Future<http.Response> get(String path, {String? baseUrl}) async {
    final url = baseUrl ?? await getBaseUrl();
    return await http.get(Uri.parse('$url/$path'));
  }

  Future<http.Response> post(String path, {Map<String, dynamic>? body}) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl/$path');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  Future<http.StreamedResponse> postFile(String path, File file) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl/$path');

    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('source', file.path));

    return await request.send();
  }

  Future<Uint8List> getBytes(String path) async {
    final baseUrl = await getBaseUrl();
    final url = Uri.parse('$baseUrl/$path');

    int retryCount = 0;
    const maxRetries = 3;
    const initialDelay = Duration(seconds: 1);

    while (true) {
      try {
        final request = http.Request('GET', url);
        request.headers['Connection'] = 'keep-alive';

        final streamedResponse = await _client
            .send(request)
            .timeout(const Duration(seconds: 30));

        final completer = Completer<Uint8List>();
        final chunks = <List<int>>[];

        streamedResponse.stream.listen(
          (chunk) => chunks.add(chunk),
          onDone: () {
            final bytes = Uint8List.fromList(chunks.expand((x) => x).toList());
            completer.complete(bytes);
          },
          onError: completer.completeError,
          cancelOnError: true,
        );

        return await completer.future;
      } catch (e) {
        if (retryCount >= maxRetries) rethrow;

        retryCount++;
        final delay = initialDelay * (1 << retryCount);
        print('Retry $retryCount after ${delay.inSeconds}s: $e');
        await Future.delayed(delay);
      }
    }
  }

  void dispose() {
    _client.close();
  }
}
