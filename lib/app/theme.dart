import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF2B2340);
  static const green = Color(0xFF4CD964);
  static const greenDark = Color(0xFF2E9E45);
  static const orange = Color(0xFFFFA62B);
  static const orangeDark = Color(0xFFD9740B);
  static const blue = Color(0xFF3DA5F5);
  static const blueDark = Color(0xFF1F6FB8);
  static const pink = Color(0xFFFF5C8A);
  static const pinkDark = Color(0xFFC92D5C);
  static const grey = Color(0xFFB7B3C9);
  static const greyDark = Color(0xFF8A85A3);
  static const coin = Color(0xFFFFC928);
  static const panel = Color(0xFFFFFFFF);
  static const panelSoft = Color(0xFFF3EFFC);
  static const danger = Color(0xFFFF3B47);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.pink),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
    splashFactory: NoSplash.splashFactory,
  );
}
