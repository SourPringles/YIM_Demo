import 'package:http/http.dart' as http;

class ServiceUtils {
  // 서버에 닉네임 업데이트 요청
  static Future<void> updateNickname(String uuid, String nickname) async {
    // 엔드포인트 형식: '/rename/uid/변경닉네임'
    final response = await http.post(
      Uri.parse('http://localhost:5000/rename/$uuid/$nickname'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update: ${response.statusCode}');
    }
  }
}
