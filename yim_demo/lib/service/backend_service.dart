import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class BackendService {
  bool isLocalHost = false; // 스위치 상태를 저장하는 변수
  String serverAddress = "25.28.228.203"; // 기본 서버 주소
  String port = "9064"; // 기본 포트

  void updateServerSettings({
    required bool isLocalHost,
    required String serverAddress,
    required String port,
  }) {
    this.isLocalHost = isLocalHost;
    this.serverAddress = serverAddress;
    this.port = port;
  }

  Future<bool> connectionSetting() async {
    Uri url;
    if (isLocalHost) {
      url = Uri.parse("http://localhost:5000/connectionTest");
    } else {
      url = Uri.parse("http://$serverAddress:$port/connectionTest");
    }

    try {
      final response = await http.get(url);
      return response.statusCode == 200;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<List<Map<String, String>>> fetchInventory() async {
    Uri url;
    if (isLocalHost) {
      url = Uri.parse("http://localhost:5000/getStorage");
    } else {
      url = Uri.parse("http://$serverAddress:$port/getStorage");
    }

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // JSON 데이터가 리스트 형태라고 가정하고 디코딩
        final List<dynamic> data = json.decode(response.body);

        // JSON 데이터 처리 (리스트 순회)
        return data.map((itemData) {
          // 각 항목이 Map 형태라고 가정하고 캐스팅
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
        print('Failed to fetch inventory: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // 오류 발생 시 타입 캐스팅 오류 등을 포함하여 출력
      print('Error fetching inventory: $e');
      return [];
    }
  }

  Future<void> uploadItem(Map<String, String> item) async {
    Uri url;
    if (isLocalHost) {
      url = Uri.parse("http://localhost:5000/updateStorage");
    } else {
      url = Uri.parse("http://$serverAddress:$port/updateStorage");
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(item),
      );
      if (response.statusCode == 200) {
        print('Item uploaded successfully');
      } else {
        print('Failed to upload item: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading item: $e');
    }
  }

  Future<void> updateNickname(String uid, String newNickname) async {
    Uri url;
    if (isLocalHost) {
      url = Uri.parse("http://localhost:5000/rename/$uid/$newNickname");
    } else {
      url = Uri.parse("http://$serverAddress:$port/rename/$uid/$newNickname");
    }

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        print('Nickname updated successfully');
      } else {
        print('Failed to update nickname: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating nickname: $e');
    }
  }

  Future<bool> uploadImage(BuildContext context) async {
    try {
      // 이미지 선택
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        print('No image selected');
        return false; // 이미지 선택 취소 시 false 반환
      }

      final file = File(pickedFile.path);

      // 서버 URL 설정
      Uri url;
      if (isLocalHost) {
        url = Uri.parse("http://localhost:5000/updateStorage");
      } else {
        url = Uri.parse("http://$serverAddress:$port/updateStorage");
      }

      // 이미지 업로드
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('source', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        print('Image uploaded successfully');
        return true; // 성공 시 true 반환
      } else {
        print('Failed to upload image: ${response.statusCode}');
        return false; // 실패 시 false 반환
      }
    } catch (e) {
      print('Error uploading image: $e');
      return false; // 실패 시 false 반환
    }
  }
}
