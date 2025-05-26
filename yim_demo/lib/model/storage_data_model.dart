import 'package:flutter/material.dart';

class StorageData {
  List<dynamic> _storageItems = [];
  // [{uuid: '', nickname: '', timestamp: '', x: '', y: ''}]
  List<dynamic> _tempItems = [];
  // [{uuid: '', nickname: '', timestamp: ''}]
  Image? _backgroundImage;

  List<dynamic> get storageItems => _storageItems;
  List<dynamic> get tempItems => _tempItems;
  Image? get backgroundImage => _backgroundImage;

  StorageData();

  void setStorageItems(List<dynamic> items) {
    _storageItems = items;
  }

  void setTempItems(List<dynamic> items) {
    _tempItems = items;
  }

  void setBackgroundImage(Image? image) {
    if (image == null) {
      _backgroundImage = null;
      return;
    } else {
      _backgroundImage = image;
    }
  }

  void clearStorageData() {
    _storageItems = [];
    _tempItems = [];
    _backgroundImage = null;
  }

  List<Map<String, dynamic>> getAbandonedItems(Duration threshold) {
    final now = DateTime.now();
    List<Map<String, dynamic>> abandonedItems = [];

    for (var item in _storageItems) {
      if (item is Map && item.containsKey('timestamp')) {
        try {
          final DateTime itemDate = DateTime.parse(item['timestamp']);
          final difference = now.difference(itemDate);

          if (difference >= threshold) {
            abandonedItems.add(Map<String, dynamic>.from(item));
          }
        } catch (e) {
          print('날짜 파싱 오류: $e');
        }
      }
    }

    return abandonedItems;
  }
}
