import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
      useMaterial3: true,
    );
  }
}
