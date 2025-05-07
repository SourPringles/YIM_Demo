import 'package:flutter/material.dart';

import '../service/listviewpage_service.dart';
import '../views/view_utils.dart';

class LVP extends StatefulWidget {
  const LVP({super.key});

  @override
  State<LVP> createState() => _LVPState();
}

class _LVPState extends State<LVP> {
  final LVPService _lvpService = LVPService();

  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStorage();
  }

  Future<void> _loadStorage() async {
    final items = await _lvpService.loadStorage();
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text('List View Page'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStorage),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: ListTile(
                      leading:
                          item['uuid'] != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  'http://localhost:5000/getImage/${item['uuid']}',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.image_not_supported),
                                      ),
                                ),
                              )
                              : null,
                      title: Text(item['nickname'] ?? 'Unknown'),
                      subtitle: Text('${item['timestamp'] ?? 'Unknown'}'),
                      onTap:
                          () => DialogUtils.showItemDetails(
                            context,
                            item,
                            onClose: _loadStorage,
                          ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  );
                },
              ),
    );
  }
}
