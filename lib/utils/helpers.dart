import 'package:flutter/material.dart';

IconData getIconFromString(String iconName) {
  switch (iconName) {
    case 'local_hospital': return Icons.local_hospital;
    case 'local_police': return Icons.local_police;
    case 'airport_shuttle': return Icons.airport_shuttle;
    case 'fire_truck': return Icons.fire_truck;
    case 'school': return Icons.school;
    case 'landscape': return Icons.landscape;
    case 'info_outline': return Icons.info_outline;
    case 'article_outlined': return Icons.article_outlined;
    case 'local_library': return Icons.local_library;
    case 'hotel': return Icons.hotel;
    default: return Icons.apps;
  }
}

Color getColorFromString(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  return Color(int.parse(hexColor, radix: 16));
}