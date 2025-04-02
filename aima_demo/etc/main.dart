import 'package:flutter/material.dart';
import 'service/backend_service.dart';
import 'settings_dialog.dart';
import 'service/location_service.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainPage(),
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600, // 가로 600
              maxHeight: 1200, // 세로 1200
            ),
            child: ClipRect(child: child),
          ),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final BackendService _backendService = BackendService();
  List<Map<String, String>> _items = [];
  bool _isFirstLoad = true;
  //String _connectionStatus = ""; // 연결 상태 메시지

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showSettingsDialog(
        onClose: () {
          _fetchInventory();
        },
      );
    });
  }

  Future<void> _fetchInventory() async {
    final items = await _backendService.fetchInventory();
    setState(() {
      _items = items;
      _isFirstLoad = false;
    });
  }

  void _showSettingsDialog({VoidCallback? onClose}) {
    showDialog(
      context: context,
      barrierDismissible: false, // 주변 여백 클릭으로 닫히지 않도록 설정
      builder: (BuildContext context) {
        return SettingsDialog(backendService: _backendService);
      },
    ).then((_) {
      if (onClose != null) onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MainPage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchInventory,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isFirstLoad
                    ? const Center(child: CircularProgressIndicator())
                    : (_items.isEmpty
                        ? const Center(child: Text('No items found'))
                        : ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return ListTile(
                              title: Text(item["nickname"] ?? ""),
                              subtitle: Text(
                                "QR Code: ${item["qr_code"] ?? ""}\n"
                                "Last Modified: ${item["lastModified"] ?? ""}\n"
                                "Position: (${item["x"]}, ${item["y"]})",
                              ),
                              leading: const Icon(Icons.kitchen),
                              trailing: const Icon(Icons.arrow_forward),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => LocationPage(
                                          backendService: _backendService,
                                          highlightedItem: item,
                                        ),
                                  ),
                                );
                                _fetchInventory(); // 복귀 후 새로고침
                              },
                            );
                          },
                        )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              LocationPage(backendService: _backendService),
                    ),
                  );
                  _fetchInventory(); // 복귀 후 새로고침
                },
                child: const Text('물건 위치 보기'),
              ),
              ElevatedButton(
                onPressed: _uploadImage,
                child: const Text('이미지 업로드'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImage() async {
    final result = await _backendService.uploadImage(context);
    if (!mounted) return; // 위젯이 마운트되어 있는지 확인
    if (result) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미지 업로드 성공')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미지 업로드 실패')));
    }

    await _fetchInventory();
  }
}

class LocationPage extends StatefulWidget {
  final BackendService backendService;
  final Map<String, String>? highlightedItem;

  const LocationPage({
    super.key,
    required this.backendService,
    this.highlightedItem,
  });

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  late final LocationService _locationService;
  List<Map<String, String>> _items = [];
  bool _isLoading = true;
  Map<String, String>? _highlightedItem; // 현재 강조된 물건

  @override
  void initState() {
    super.initState();
    _locationService = LocationService(widget.backendService);
    _highlightedItem = widget.highlightedItem; // 초기 강조된 물건 설정
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    final items = await _locationService.fetchLocations();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  void _clearHighlight() {
    setState(() {
      _highlightedItem = null; // 강조된 물건 초기화
    });
  }

  Future<void> _updateNickname(String qrCode, String newNickname) async {
    await widget.backendService.updateNickname(qrCode, newNickname);
    await _fetchLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('물건 위치 보기'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLocations,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children:
                    _items.map((item) {
                      final double x = double.tryParse(item["x"] ?? "0") ?? 0;
                      final double y = double.tryParse(item["y"] ?? "0") ?? 0;
                      final bool isHighlighted =
                          _highlightedItem != null &&
                          _highlightedItem!["qr_code"] == item["qr_code"];
                      return Positioned(
                        left: x,
                        top: y,
                        child: GestureDetector(
                          onTap: () {
                            _showItemDetailsDialog(item);
                            _clearHighlight(); // 강조 초기화
                          },
                          child: Container(
                            width: 90, // 가로 90
                            height: 30, // 세로 30
                            decoration: BoxDecoration(
                              color: isHighlighted ? Colors.red : Colors.blue,
                              shape: BoxShape.rectangle, // 사각형 형태
                            ),
                            child: Center(
                              child: Text(
                                item["nickname"] ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12, // 텍스트 크기 조정
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
    );
  }

  void _showItemDetailsDialog(Map<String, String> item) {
    final TextEditingController nicknameController = TextEditingController(
      text: item["nickname"],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item["nickname"] ?? "Unknown"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    children: [
                      const Text('QR Code:'),
                      Text(item["qr_code"] ?? "Unknown"),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('Last Modified:'),
                      Text(item["lastModified"] ?? "Unknown"),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Text('Position:'),
                      Text("(${item["x"]}, ${item["y"]})"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(labelText: 'Edit Nickname'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('닫기'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newNickname = nicknameController.text;
                await _updateNickname(item["qr_code"] ?? "", newNickname);
                Navigator.pop(context);
              },
              child: const Text('수정'),
            ),
          ],
        );
      },
    );
  }
}
