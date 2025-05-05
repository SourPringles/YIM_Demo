import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UIPService {
  // 서버 설정
  final String baseUrl = "http://localhost:5000";

  // 이미지 업로드 함수
  Future<Map<String, dynamic>> uploadImage(
    File imageFile,
    String nickname,
  ) async {
    final url = Uri.parse('$baseUrl/updateStorage');

    // 멀티파트 요청 생성
    var request = http.MultipartRequest('POST', url);

    // 이미지 파일 추가
    var fileStream = http.ByteStream(imageFile.openRead());
    var fileLength = await imageFile.length();

    var multipartFile = http.MultipartFile(
      'source',
      fileStream,
      fileLength,
      filename: imageFile.path.split("/").last,
    );

    // 요청에 파일 및 닉네임 추가
    request.files.add(multipartFile);
    request.fields['nickname'] = nickname;

    // 요청 전송 및 응답 대기
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    // 응답 처리
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to upload image: ${response.statusCode}');
    }
  }
}
