Duration compareDatesDuration(String timestamp) {
  DateTime itemTimestamp = DateTime.parse(timestamp);
  DateTime currentTimestamp = DateTime.now();

  Duration difference = currentTimestamp.difference(itemTimestamp);

  try {
    // print(
    //   '두 날짜의 차이: ${difference.inDays}일 ${difference.inHours % 24}시간 '
    //   '${difference.inMinutes % 60}분 ${difference.inSeconds % 60}초',
    // );
    return difference;
  } catch (e) {
    //print('Error calculating date difference: $e');
    return Duration.zero;
  }
}

// for test
String getDateDiffDays(String date) {
  Duration duration = compareDatesDuration(date);
  return '${duration.inDays}일 전';
}
