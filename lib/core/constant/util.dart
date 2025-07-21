import 'package:flutter/cupertino.dart';

Color strengthnColor(Color color, double strength) {
  int r = (color.red * strength).clamp(0, 255).toInt();
  int g = (color.green * strength).clamp(0, 225).toInt();
  int b = (color.blue).clamp(0, 255).toInt();
  return Color.fromARGB(color.alpha, r, g, b);
}

List<DateTime> generateWeekDates(DateTime base, int weekOffset) {
  DateTime startOfWeek = base.add(Duration(days: weekOffset * 7));
  return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
}

String rgbToHex(Color color) {
  return '${color.red.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}';
}

Color hexToRgb(String hex) {
  return Color(int.parse(hex, radix: 16) + 0xFF000000);
}
