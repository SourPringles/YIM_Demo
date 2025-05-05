import 'package:flutter/material.dart';
import '../service/config_service.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({Key? key}) : super(key: key);

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  // 병합된 서비스 사용
  final _ConfigService = ConfigService();
  bool _useLocalhost = true;
  final _serverAddressController = TextEditingController();
  final _portController = TextEditingController();
  bool _isConnectionTested = false;
  bool _isConnectionSuccessful = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _ConfigService.getServerSettings();
    setState(() {
      _useLocalhost = settings['useLocalhost'];
      _serverAddressController.text = settings['serverAddress'];
      _portController.text = settings['serverPort'];
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _isConnectionTested = false;
    });

    final result = await _ConfigService.testConnection(
      useLocalhost: _useLocalhost,
      serverAddress: _serverAddressController.text,
      serverPort: _portController.text,
    );

    setState(() {
      _isLoading = false;
      _isConnectionTested = true;
      _isConnectionSuccessful = result;
    });

    if (result) {
      await _ConfigService.saveServerSettings(
        useLocalhost: _useLocalhost,
        serverAddress: _serverAddressController.text,
        serverPort: _portController.text,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('서버 설정이 저장되었습니다.')));
    }
  }

  @override
  void dispose() {
    _serverAddressController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '서버 설정',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                Switch(
                  value: _useLocalhost,
                  onChanged: (value) {
                    setState(() {
                      _useLocalhost = value;
                      _isConnectionTested = false;
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text('로컬 서버 사용 (localhost)'),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _serverAddressController,
              decoration: const InputDecoration(
                labelText: '서버 주소',
                border: OutlineInputBorder(),
                hintText: '예: 192.168.0.1',
              ),
              enabled: !_useLocalhost,
              onChanged: (_) => setState(() => _isConnectionTested = false),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: '포트',
                border: OutlineInputBorder(),
                hintText: '예: 8080',
              ),
              onChanged: (_) => setState(() => _isConnectionTested = false),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testConnection,
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('서버 연결 테스트'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed:
                      _isConnectionSuccessful
                          ? () => Navigator.of(context).pop()
                          : null,
                  child: const Text('확인'),
                ),
              ],
            ),
            if (_isConnectionTested) ...[
              const SizedBox(height: 16),
              Text(
                _isConnectionSuccessful
                    ? '서버 연결에 성공했습니다!'
                    : '서버 연결에 실패했습니다. 설정을 확인해주세요.',
                style: TextStyle(
                  color: _isConnectionSuccessful ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 기존의 SettingsPage는 유지 (다른 곳에서 사용하는 경우가 있을 수 있으므로)
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SettingsDialog();
  }
}

// 팝업 대화상자를 표시하는 함수
void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const SettingsDialog();
    },
  );
}
