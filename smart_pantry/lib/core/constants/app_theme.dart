import 'package:flutter/material.dart';
import 'package:smart_pantry/core/constants/app_colors.dart';

class AppTheme {
  static const double minTouchTarget = 60.0;
  static const double bodyTextSize = 18.0;
  static const double titleTextSize = 24.0;
  static const double headingTextSize = 28.0;
  static const double cardRadius = 14.0;
  static const double buttonRadius = 14.0;
  
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;

  static ThemeData get elderlyTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),

      // ลบส่วน cardTheme ออกเพื่อแก้ Error
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, minTouchTarget),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
        ),
      ),
    );
  }
}