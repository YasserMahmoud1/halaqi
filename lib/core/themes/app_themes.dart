import 'package:flutter/material.dart';
import 'package:my_barber/core/themes/app_colors.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.white,
    primaryColor: AppColors.goldDark,
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.goldDark,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.bottomNavBarBackgroundLight,
      selectedItemColor: AppColors.goldDark,
      unselectedItemColor: AppColors.greyDark,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.black,
    primaryColor: AppColors.goldLight,
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.goldLight,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.bottomNavBarBackgroundDark,
      selectedItemColor: AppColors.goldLight,
      unselectedItemColor: AppColors.greyLight,
    ),
  );
}
