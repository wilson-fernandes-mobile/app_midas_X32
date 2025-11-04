import 'package:flutter/material.dart';

class FaderColorHelper {

  static Color getLevelColor(double level) {
    if (level < 0.30) {
      return Colors.blue;
    } else if (level >= 0.30 && level < 0.68) {
      return Colors.amber;
    } else if (level >= 0.68 && level <= 0.82) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }
}