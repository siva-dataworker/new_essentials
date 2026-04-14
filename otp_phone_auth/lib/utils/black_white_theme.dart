import 'package:flutter/material.dart';

class BWColors {
  // Black & White theme used for supervisor dashboard only
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF6F6F6);
  static const Color card = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF000000);
  static const Color secondaryText = Color(0xFF616161);
  static const Color muted = Color(0xFF9E9E9E);
  static const Color border = Color(0xFFE0E0E0);

  static const LinearGradient bwGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF757575)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
