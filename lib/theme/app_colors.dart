import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Colors
  static const Color primary = Color(0xFF8C1F2B);
  static const Color primaryLightTint = Color(0xFFF6DCDE);
  static const Color primaryTextOnWhite = Color(0xFF8C1F2B);
  static const Color primaryOnTintText = Color(0xFF8C1F2B);
  static const Color whiteTextOnPrimary = Color(0xFFFBE6E8);

  // Neutrals
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B68);
  static const Color textMuted = Color(0xFF9C9C98);
  static const Color border = Color(0xFFE5E3DD);
  static const Color borderStrong = Color(0xFFD3D1C7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color pageBackground = Color(0xFFF7F6F2);
  static const Color mapBase = Color(0xFFE8E6E1);
  static const Color mapGridRoads = Color(0xFFDEDCD6);

  // Status Colors (Requests/Availability)
  static const Color statusUrgentBg = Color(0xFFF6DCDE);
  static const Color statusUrgentText = Color(0xFF8C1F2B);

  static const Color statusPendingBg = Color(0xFFFAEEDA);
  static const Color statusPendingText = Color(0xFF854F0B);

  static const Color statusAvailableBg = Color(0xFFEAF3DE);
  static const Color statusAvailableText = Color(0xFF3B6D11);

  static const Color statusCompletedBg = Color(0xFFEAF3DE);
  static const Color statusCompletedText = Color(0xFF3B6D11);
}
