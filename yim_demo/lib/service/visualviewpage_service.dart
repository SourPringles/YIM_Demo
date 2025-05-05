import 'package:http/http.dart' as http;
import 'dart:convert';

class VVPService {
  bool isLocalHost;
  String serverAddress;
  String port;

  VVPService({
    this.isLocalHost = true, // 기본값 설정
    this.serverAddress = "",
    this.port = "",
  });

  // 서버 설정 변경
  void updateServerSettings({
    required bool isLocalHost,
    required String serverAddress,
    required String port,
  }) {
    this.isLocalHost = isLocalHost;
    this.serverAddress = serverAddress;
    this.port = port;
  }

  // 서버에서 물건 데이터 가져오기
  Future<List<Map<String, dynamic>>> loadStorage() async {
    Uri url;

    //if (isLocalHost) {
    //  url = Uri.parse("http://localhost:5000/getStorage");
    //} else {
    //  url = Uri.parse("http://$serverAddress:$port/getStorage");
    //}

    url = Uri.parse("http://localhost:5000/getStorage");

    try {
      final response = await http.get(url);
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
        print('Failed to fetch storage: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // 오류 발생 시 타입 캐스팅 오류 등을 포함하여 출력
      print('Error fetching storage: $e');
      return [];
    }
  }
}
