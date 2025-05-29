// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/common_data_provider.dart';
import '../theme/component_styles.dart'; // 테마 스타일 임포트

class TestView extends StatefulWidget {
  const TestView({super.key});

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  late TextEditingController ipController;
  late TextEditingController portController;
  bool isLocalhost = false; // 기본값을 false로 설정

  @override
  void initState() {
    super.initState();
    ipController = TextEditingController();
    portController = TextEditingController();

    // 다음 프레임에서 초기화 (build 후)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final commonData = Provider.of<CommonDataProvider>(
        context,
        listen: false,
      );
      ipController.text = commonData.getServerUrl();
      portController.text = commonData.getServerPort();
      setState(() {
        isLocalhost = commonData.getIsLocalhost();
      });
    });
  }

  @override
  void dispose() {
    ipController.dispose();
    portController.dispose();
    super.dispose();
  }

  // 버튼 클릭 시 로딩 다이얼로그를 표시하는 함수
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: ComponentStyles.dialogShape, // 분리된 스타일 사용
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: ComponentStyles.tossBlue, // Toss 블루 색상 사용
              ),
              const SizedBox(width: 20),
              const Text(
                "서버에 연결 중...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Page'),
        elevation: 0, // 그림자 제거
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 서버 설정 입력 폼
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '서버 설정',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // IP 주소 입력
                    TextField(
                      controller: ipController,
                      decoration: InputDecoration(
                        labelText: 'IP 주소',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 포트 입력
                    TextField(
                      controller: portController,
                      decoration: InputDecoration(
                        labelText: '포트',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),

                    // Localhost ON/OFF 토글 버튼
                    Row(
                      children: [
                        Text(
                          'Localhost:',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Switch(
                          value: isLocalhost,
                          activeColor: theme.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              isLocalhost = value;
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isLocalhost ? 'ON' : 'OFF',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isLocalhost ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 적용 버튼
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () async {
                        _showLoadingDialog(context);

                        // 비동기 작업 수행
                        await context
                            .read<CommonDataProvider>()
                            .changeHttpConnection(
                              isLocalhost,
                              ipController.text,
                              portController.text,
                            );

                        await context.read<CommonDataProvider>().refreshData();

                        // 작업 완료 후 로딩 다이얼로그 닫기
                        _hideLoadingDialog(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '서버 설정이 변경되었습니다 (localhost: $isLocalhost)',
                            ),
                            backgroundColor: theme.primaryColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('설정 적용'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Consumer<CommonDataProvider>(
                builder: (context, data, child) {
                  return Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '현재 서버 설정',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          'Localhost',
                          data.httpConnection.isLocalhost.toString(),
                        ),
                        _buildInfoRow('URL', data.httpConnection.url),
                        _buildInfoRow('PORT', data.httpConnection.port),

                        const SizedBox(height: 24),
                        Text(
                          '저장소 데이터',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        data.storageData.backgroundImage ??
                            const Text('No Image'),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          '아이템 수',
                          data.storageData.storageItems.length.toString(),
                        ),
                        _buildInfoRow(
                          '임시 아이템 수',
                          data.storageData.tempItems.length.toString(),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // 버튼들을 가로로 배치
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        _showLoadingDialog(context);
                        await context.read<CommonDataProvider>().refreshData();
                        _hideLoadingDialog(context);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("새로고침"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        _showLoadingDialog(context);
                        context.read<CommonDataProvider>().resetAll();
                        await context.read<CommonDataProvider>().refreshData();
                        _hideLoadingDialog(context);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text("RESET"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 프리셋 버튼들 (같은 줄에 2개씩)
              Text(
                '빠른 설정',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await context
                            .read<CommonDataProvider>()
                            .changeHttpConnection(false, '10.0.2.2', '5000');

                        setState(() {
                          ipController.text = '10.0.2.2';
                          portController.text = '5000';
                          isLocalhost = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Android"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<CommonDataProvider>().changeHttpConnection(
                          true,
                          '192.168.0.1',
                          '5000',
                        );
                        setState(() {
                          ipController.text = '192.168.0.1';
                          portController.text = '5000';
                          isLocalhost = true;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Win/localhost"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<CommonDataProvider>().changeHttpConnection(
                          false,
                          '127.0.0.1',
                          '5000',
                        );
                        setState(() {
                          ipController.text = '127.0.0.1';
                          portController.text = '5000';
                          isLocalhost = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Local/127.0.0.1"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<CommonDataProvider>().changeHttpConnection(
                          false,
                          'localhost',
                          '5000',
                        );
                        setState(() {
                          ipController.text = 'localhost';
                          portController.text = '5000';
                          isLocalhost = false;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("localhost"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
