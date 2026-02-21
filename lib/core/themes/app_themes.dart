import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    brightness: Brightness.light,
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      secondary: AppColors.secondary,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      color: AppColors.backgroundLight,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColors.backgroundLight,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    brightness: Brightness.dark,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      secondary: AppColors.secondary,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      color: AppColors.backgroundDark,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColors.backgroundDark,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    useMaterial3: true,
  );
}
