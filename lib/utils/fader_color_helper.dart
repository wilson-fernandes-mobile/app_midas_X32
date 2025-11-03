import 'package:flutter/material.dart';

class FaderColorHelper {

  static Color getLevelColor(double level) {
    if (level < 0.30) {
      // Muito baixo (próximo de -60dB ou menos) = Azul
      return Colors.blue;
    } else if (level >= 0.30 && level <= 0.73) {
      // Abaixo de 0dB = Amarelo
      return Colors.amber;
    } else if (level >= 0.74 && level <= 0.76) {
      // Em 0dB (com tolerância) = Verde
      return Colors.green;
    } else {
      // Acima de 0dB = Vermelho
      return Colors.red;
    }
  }
}