import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Serif display treatment (Newsreader) for headlines/names/stat numbers
/// only, per the Claude Design prototype. Body/labels/buttons/nav/forms stay
/// on AppTheme's default sans — never call this for those.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle display({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.textPrimary,
    double? height,
  }) {
    return GoogleFonts.newsreader(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }
}
