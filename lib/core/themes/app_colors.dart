import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const black = Color(0xFF0C0C0C);
  static const white = Color(0xFFFFFFFF);

  static const goldLight = Color(0xFFFFB300);
  static const goldDark = Color(0xFFBB860A);
  // BB86F2

  static const greyLight = Color(0xFFB0B0B0);
  static const greyDark = Color(0xFF4F4F4F);
  static const bottomNavBarBackgroundDark = Color(0xFF232323);
  static const bottomNavBarBackgroundLight = Color(0xFFDDDDDD);

  static const borderColorDark = Color(0xFF909090);

  /// Returns a theme-aware grey for regular text.
  ///
  /// Example: `AppColors.textGrey(context)` or `context.textGrey` via the
  /// provided extension.
  static Color textGrey(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? greyLight : greyDark;

  static Color scaffoldBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? black : white;

  static Color inverseScaffoldBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? white : black;

  static Color primaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? goldLight : goldDark;

  static Color tffBorderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? white : borderColorDark;

  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1E1E1E)
      : Colors.white;
}
