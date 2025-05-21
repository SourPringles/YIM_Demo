import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/common_data_provider.dart';

class TestView extends StatefulWidget {
  const TestView({super.key});

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  late TextEditingController ipController;
  late TextEditingController portController;
  // 기본값 설정으로 초기화 오류 방지
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

  @override
  Widget build(BuildContext context) {
    //final commonData = Provider.of<CommonDataProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Debug Page')),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 서버 설정 입력 폼
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '서버 설정',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // IP 주소 입력
                    TextField(
                      controller: ipController,
                      decoration: const InputDecoration(
                        labelText: 'IP 주소',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 포트 입력
                    TextField(
                      controller: portController,
                      decoration: const InputDecoration(
                        labelText: '포트',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Localhost ON/OFF 토글 버튼
                    Row(
                      children: [
                        const Text('Localhost:'),
                        const SizedBox(width: 10),
                        Switch(
                          value: isLocalhost,
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

                    const SizedBox(height: 16),

                    // 적용 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          context
                              .read<CommonDataProvider>()
                              .changeHttpConnection(
                                isLocalhost,
                                ipController.text,
                                portController.text,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '서버 설정이 변경되었습니다 (localhost: $isLocalhost)',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('설정 적용'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Consumer<CommonDataProvider>(
                builder: (context, data, child) {
                  return Column(
                    children: [
                      const Text(
                        '현재 서버 설정',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Localhost: ${data.httpConnection.isLocalhost.toString()}',
                      ),
                      const SizedBox(height: 5),
                      Text('URL: ${data.httpConnection.url}'),
                      const SizedBox(height: 5),
                      Text('PORT: ${data.httpConnection.port}'),

                      const SizedBox(height: 20),
                      const Text(
                        '저장소 데이터',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      data.storageData.backgroundImage ??
                          const Text('No Image'),
                      const SizedBox(height: 10),
                      Text('아이템 수: ${data.storageData.storageItems.length}'),
                      const SizedBox(height: 5),
                      Text('임시 아이템 수: ${data.storageData.tempItems.length}'),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // 버튼들을 가로로 배치
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<CommonDataProvider>().refreshData();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("새로고침"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<CommonDataProvider>().resetAll();
                      context.read<CommonDataProvider>().refreshData();
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text("RESET"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 프리셋 버튼들 (같은 줄에 2개씩)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<CommonDataProvider>().changeHttpConnection(
                          false,
                          '10.0.2.2',
                          '5000',
                        );
                        setState(() {
                          ipController.text = '10.0.2.2';
                          portController.text = '5000';
                          isLocalhost = false;
                        });
                      },
                      child: const Text("Android"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
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
                      child: const Text("Win/localhost"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
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
                      child: const Text("Local/127.0.0.1"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
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
}
