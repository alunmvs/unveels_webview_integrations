import 'package:flutter/material.dart';

class ColorConfig {
  static const Color primary = Color(0xFFCA9C43);
  static const Color secondary = Color(0xFF473209);
  static const Color black1 = Color(0xFF060606);
  static const Color black2 = Color(0xFF282828);
  static const Color black3 = Color(0xFF505050);
  static const Color textGrey1 = Color(0xFFB7B7B7);
  static const Color textGrey2 = Color(0xFFAEAEAE);
  static const Color textGrey3 = Color(0xFF828282);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color redError = Color(0xFFFF7070);
  static const Color greenSuccess = Color(0xFF4CAF50);
  static const Color yellowPending = Color(0xFFEAD414);
  static const Color tableHeader = Color(0xFFF6F6F6);
  static const Color border = Color(0xFFDDDDDD);
  static const Color green = Color(0xFF00FF38);
  static const Color purple = Color(0xFF6B13B1);
  static const Color oceanBlue = Color(0xFF00E0FF);
  static const Color blue = Color(0xFF0F38CC);
  static const Color yellow = Color(0xFFF4EB24);
  static const Color taffi = Color(0xFFE9A0DD);
  static const Color pink = Color(0xFFF72585);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      primary,
      secondary,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const verticalGradient = LinearGradient(
    colors: [
      primary,
      secondary,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const horizontalGradient = LinearGradient(
    colors: [
      primary,
      secondary,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static Color disable = Colors.grey.withOpacity(0.2);
}
