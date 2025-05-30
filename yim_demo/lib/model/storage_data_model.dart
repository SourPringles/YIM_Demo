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

  // 타임스탬프 문자열을 DateTime으로 변환하는 메서드
  DateTime? _parseDateTime(dynamic timestamp) {
    if (timestamp == null) return null;

    try {
      if (timestamp is String) {
        return DateTime.parse(timestamp);
      } else if (timestamp is int) {
        // Unix 타임스탬프(밀리초)인 경우
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    } catch (e) {
      //print('날짜 파싱 오류: $timestamp - $e');
    }

    return null;
  }

  // 두 날짜 간의 차이를 계산하는 메서드
  Duration _getDateDifference(DateTime? itemDate) {
    if (itemDate == null) return Duration.zero;

    DateTime currentDate = DateTime.now();
    return currentDate.difference(itemDate);
  }

  /// 7일 이상 방치된 항목 개수를 반환합니다.
  int getAbandonedItemsCount() {
    final sevenDays = Duration(days: 7);
    int count = 0;

    //print('현재 시간: ${DateTime.now()}');

    // storageItems 확인
    for (var item in _storageItems) {
      DateTime? itemDate = _parseDateTime(item['timestamp']);

      if (itemDate != null) {
        Duration difference = _getDateDifference(itemDate);
        //print(
        //  '아이템: ${item['nickname'] ?? "이름 없음"}, 날짜: ${item['timestamp']}, 경과 시간: ${difference.inDays}일',
        //);

        // 7일 이상 지났는지 확인
        if (difference >= sevenDays) {
          count++;
          //print(
          //  '방치된 항목 발견: ${item['nickname'] ?? "이름 없음"}, 경과 일수: ${difference.inDays}일',
          //);
        }
      }
    }
    //print('총 방치된 항목 수: $count');
    return count;
  }

  /// 7일 이상 방치된 항목 목록을 반환합니다.
  List<dynamic> getAbandonedItems() {
    final sevenDays = Duration(days: 7);
    List<dynamic> abandonedItems = [];

    // storageItems에서 7일 이상 지난 항목 찾기
    for (var item in _storageItems) {
      DateTime? itemDate = _parseDateTime(item['timestamp']);

      if (itemDate != null) {
        Duration difference = _getDateDifference(itemDate);

        if (difference >= sevenDays) {
          abandonedItems.add(item);
        }
      }
    }

    return abandonedItems;
  }
}
