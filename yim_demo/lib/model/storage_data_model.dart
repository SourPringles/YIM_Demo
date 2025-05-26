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
}
