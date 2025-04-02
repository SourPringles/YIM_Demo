import 'package:flutter/material.dart';
import 'service/backend_service.dart';

class SettingsDialog extends StatefulWidget {
  final BackendService backendService;

  const SettingsDialog({super.key, required this.backendService});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late TextEditingController _serverController;
  late TextEditingController _portController;
  String _connectionStatus = ""; // 연결 상태 메시지
  bool _isTestingConnection = false; // 연결 테스트 중 상태
  bool _isCloseButtonEnabled = false; // 닫기 버튼 활성화 상태

  @override
  void initState() {
    super.initState();
    _serverController = TextEditingController();
    _portController = TextEditingController();
    _updateInputFields();
  }

  void _updateInputFields() {
    if (widget.backendService.isLocalHost) {
      _serverController.text = "127.0.0.1";
      _portController.text = "5000";
    } else {
      _serverController.text = widget.backendService.serverAddress;
      _portController.text = widget.backendService.port;
    }
  }

  void _applySettings() {
    widget.backendService.updateServerSettings(
      isLocalHost: widget.backendService.isLocalHost,
      serverAddress: _serverController.text,
      port: _portController.text,
    );
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionStatus = ""; // 상태 초기화
      _isCloseButtonEnabled = false; // 닫기 버튼 비활성화
    });

    final isConnected = await widget.backendService.connectionSetting();

    setState(() {
      _isTestingConnection = false;
      _connectionStatus =
          isConnected ? "Connection Successful" : "Connection Failed";
      _isCloseButtonEnabled = isConnected; // 연결 성공 시 닫기 버튼 활성화
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('설정'),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Use LocalHost: '),
                  Switch(
                    value: widget.backendService.isLocalHost,
                    onChanged: (bool value) {
                      setDialogState(() {
                        widget.backendService.isLocalHost = value;
                        _updateInputFields();
                      });
                      setState(() {}); // 다이얼로그 상태 업데이트
                    },
                  ),
                ],
              ),
              TextField(
                controller: _serverController,
                decoration: const InputDecoration(labelText: 'Server Address'),
                enabled: !widget.backendService.isLocalHost,
                onChanged: (value) {
                  setDialogState(() {
                    widget.backendService.serverAddress = value;
                  });
                },
              ),
              TextField(
                controller: _portController,
                decoration: const InputDecoration(labelText: 'Port'),
                keyboardType: TextInputType.number,
                enabled: !widget.backendService.isLocalHost,
                onChanged: (value) {
                  setDialogState(() {
                    widget.backendService.port = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    _isTestingConnection
                        ? null // 비활성화 상태
                        : () async {
                          _applySettings(); // 설정 적용
                          await _checkConnection();
                        },
                child: Text(_isTestingConnection ? "연결중" : "Test Connection"),
              ),
              if (_connectionStatus.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _connectionStatus,
                    style: TextStyle(
                      color:
                          _connectionStatus == "Connection Successful"
                              ? Colors.green
                              : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed:
              _isCloseButtonEnabled
                  ? () {
                    _applySettings(); // 설정 적용
                    Navigator.pop(context);
                  }
                  : null, // 비활성화 상태
          child: const Text('닫기'),
        ),
      ],
    );
  }
}
