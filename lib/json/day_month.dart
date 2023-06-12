import 'package:intl/intl.dart';

List<Map<String, String>> generateDays() {
  final now = DateTime.now();
  final List<Map<String, String>> days = [];

  for (int i = -3; i <= 3; i++) {
    final date = now.add(Duration(days: i));
    final label = DateFormat('E').format(date); // short weekday name (Sun, Mon, ...)
    final fullDay = DateFormat('MM/dd/yyyy').format(date); // date in MM/dd/yyyy format
    final day = DateFormat('dd').format(date); // day in month

    days.add({
      'label': label,
      'fullday': fullDay,
      'day': day,
    });
  }

  return days;
}

List<Map<String, String>> generateMonths() {
  DateTime now = DateTime.now();
  List<Map<String, String>> result = [];

  for (int i = -5; i <= 0; i++) {
    DateTime month = DateTime(now.year, now.month + i);
    Map<String, String> monthMap = {
      "label": month.year.toString(),
      "day": DateFormat('MMM').format(month),  // abbreviated month name (Jun, Mar, ...)
      "numday": DateFormat('MM').format(month),
    };
    result.add(monthMap);
  }

  return result;
}

List days = generateDays();
List months = generateMonths();
