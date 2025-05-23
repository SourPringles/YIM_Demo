import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../provider/common_data_provider.dart';

class ImageUploadView extends StatefulWidget {
  const ImageUploadView({super.key});

  @override
  State<ImageUploadView> createState() => _ImageUploadViewState();
}

class _ImageUploadViewState extends State<ImageUploadView> {
  File? _selectedImage;
  bool _isUploading = false;
  String? _uploadResult;
  bool _hasError = false;

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 사용자가 바깥을 터치해도 닫히지 않음
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            //crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("이미지 업로드 중..."),
            ],
          ),
        );
      },
    );
  }

  // HTTP 요청 후 로딩 다이얼로그를 닫는 함수
  void _hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // 이미지 선택 함수
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _uploadResult = null;
        });
      }
    } catch (e) {
      // 카메라 접근 실패 시 처리
      setState(() {
        _uploadResult =
            source == ImageSource.camera
                ? "카메라를 사용할 수 없습니다. 기기에 카메라가 없거나 권한이 거부되었습니다."
                : "갤러리 접근에 실패했습니다.";
        _hasError = true;
      });

      // 사용자에게 알림 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? '카메라를 사용할 수 없습니다'
                  : '갤러리에 접근할 수 없습니다',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 이미지 업로드 함수
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      setState(() {
        _uploadResult = "이미지를 선택해주세요.";
        _hasError = true;
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadResult = null;
    });

    try {
      // CommonDataProvider의 HttpConnection 사용
      final provider = Provider.of<CommonDataProvider>(context, listen: false);
      _showLoadingDialog(context);

      // 파일 업로드 요청
      final response = await provider.httpConnection.postFile(
        'updateStorage',
        _selectedImage!,
      );

      _hideLoadingDialog(context);
      print(response);

      // 업로드 성공 시 데이터 갱신
      if (response.statusCode == 200) {
        provider.refreshData();

        setState(() {
          _isUploading = false;
          _uploadResult = "업로드 성공!";
          _hasError = false;
        });
      } else {
        throw Exception('업로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadResult = "업로드 실패: $e";
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 이미지 선택 버튼들
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('갤러리에서 선택'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('카메라로 촬영'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 선택한 이미지 미리보기
            Container(
              height: 300,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  _selectedImage != null
                      ? Image.file(
                        _selectedImage!,
                        height: 300,
                        fit: BoxFit.contain,
                      )
                      : const Text('이미지를 선택해주세요'),
            ),
            const SizedBox(height: 20),

            // 업로드 버튼
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadImage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child:
                  _isUploading
                      ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                      : const Text('업로드', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 15),

            // 업로드 결과 메시지
            if (_uploadResult != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _hasError ? Colors.red[100] : Colors.green[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _uploadResult!,
                  style: TextStyle(
                    color: _hasError ? Colors.red[900] : Colors.green[900],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
