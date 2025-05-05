import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../service/uploadimagepage_service.dart';

class UIP extends StatefulWidget {
  const UIP({super.key});

  @override
  State<UIP> createState() => _UIPState();
}

class _UIPState extends State<UIP> {
  final UIPService _uipService = UIPService();

  File? _selectedImage;
  bool _isUploading = false;
  String? _uploadResult;
  bool _hasError = false;

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
      final result = await _uipService.uploadImage(
        _selectedImage!,
        "NEW ITEM", // 기본값으로 고정
      );

      setState(() {
        _isUploading = false;
        _uploadResult = "업로드 성공!";
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadResult = "업로드 실패: $e";
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이미지 업로드')),
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
