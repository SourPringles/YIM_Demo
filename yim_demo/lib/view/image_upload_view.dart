import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../provider/common_data_provider.dart';
import '../theme/component_styles.dart'; // 스타일 임포트

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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: ComponentStyles.dialogShape, // 분리된 스타일 사용
          content: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF0064FF)),
              SizedBox(width: 20),
              Text(
                "이미지 업로드 중...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }

  void _hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

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
      setState(() {
        _uploadResult =
            source == ImageSource.camera
                ? "카메라를 사용할 수 없습니다. 기기에 카메라가 없거나 권한이 거부되었습니다."
                : "갤러리 접근에 실패했습니다.";
        _hasError = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? '카메라를 사용할 수 없습니다'
                  : '갤러리에 접근할 수 없습니다',
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

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
      final provider = Provider.of<CommonDataProvider>(context, listen: false);
      _showLoadingDialog(context);

      final response = await provider.httpConnection.postFile(
        'updateStorage',
        _selectedImage!,
      );

      _hideLoadingDialog(context);

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
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상단 타이틀
            Text(
              '이미지 업로드',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '이미지를 선택하고 업로드 해보세요',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // 이미지 선택 영역
            Container(
              height: 300,
              alignment: Alignment.center,
              decoration:
                  ComponentStyles.imageContainerDecoration, // 분리된 스타일 사용
              child:
                  _selectedImage != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          _selectedImage!,
                          height: 300,
                          fit: BoxFit.contain,
                        ),
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '이미지를 선택해주세요',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
            ),
            const SizedBox(height: 24),

            // 이미지 선택 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('갤러리에서 선택'),
                    // theme에 이미 적용된 스타일 사용
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('카메라로 촬영'),
                    // theme에 이미 적용된 스타일 사용
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 업로드 버튼
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadImage,
              // theme에 이미 적용된 스타일 사용
              child:
                  _isUploading
                      ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2.5,
                        ),
                      )
                      : const Text(
                        '업로드',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
            const SizedBox(height: 24),

            // 업로드 결과 메시지
            if (_uploadResult != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration:
                    _hasError
                        ? ComponentStyles
                            .errorMessageDecoration // 분리된 스타일 사용
                        : ComponentStyles
                            .successMessageDecoration, // 분리된 스타일 사용
                child: Row(
                  children: [
                    Icon(
                      _hasError
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      color: _hasError ? Colors.red[700] : Colors.green[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _uploadResult!,
                        style: TextStyle(
                          color:
                              _hasError ? Colors.red[700] : Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
