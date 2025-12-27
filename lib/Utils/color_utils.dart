import 'package:flutter/material.dart';
import 'dart:math';

class ColorUtils {
  // Her seferinde farklı bir renk üretmek için (Rastgele)
  static Color getRandomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  // Haftanın gününe özel sabit renkler
  static Color getDayColor(int weekday) {
    List<Color> colors = [
      Colors.indigo,      // Pazartesi
      Colors.orange,      // Salı
      Colors.teal,        // Çarşamba
      Colors.pinkAccent,  // Perşembe
      Colors.deepPurple,  // Cuma
      Colors.cyan,        // Cumartesi
      Colors.amber,       // Pazar
    ];
    // weekday 1-7 arası gelir (Pazartesi-Pazar)
    return colors[(weekday - 1) % colors.length];
  }

  static Color getIndexColor(int index) {
    List<Color> colors = [
      Colors.deepPurple,
      Colors.orange,
      Colors.teal,
      Colors.pinkAccent,
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
      Colors.redAccent,
      Colors.lightGreen,
      Colors.blueAccent,
    ];
    return colors[index % colors.length];
  }
}