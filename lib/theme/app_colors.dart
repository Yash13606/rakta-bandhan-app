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
  static const Color statBlockBackground = Color(0xFFECEAE4);
  static const Color tabTrackBackground = Color.fromARGB(15, 26, 26, 26);

  // Status Colors (Requests/Availability)
  static const Color statusUrgentBg = Color(0xFFF6DCDE);
  static const Color statusUrgentText = Color(0xFF8C1F2B);

  static const Color statusPendingBg = Color(0xFFFAEEDA);
  static const Color statusPendingText = Color(0xFF854F0B);

  static const Color statusAvailableBg = Color(0xFFEAF3DE);
  static const Color statusAvailableText = Color(0xFF3B6D11);

  static const Color statusCompletedBg = Color(0xFFEAF3DE);
  static const Color statusCompletedText = Color(0xFF3B6D11);

  // Gradient surfaces (Claude Design prototype's editorial hero/header treatment)
  static const Color gradientHeroStart = Color(0xFF7A1A24);
  static const Color gradientHeroEnd = Color(0xFF5C1119);
  static const Color gradientHeaderStart = Color(0xFF7A1A24);
  static const Color gradientHeaderEnd = Color(0xFF4A0E14);
  static const Color gradientAvatarStart = Color(0xFF8C1F2B);
  static const Color gradientAvatarEnd = Color(0xFF5C1119);
  static const Color gradientMatchingStart = Color(0xFF3A0F14);
  static const Color gradientMatchingEnd = Color(0xFF1A0A0C);
  static const Color gradientMarkerStart = Color(0xFFB9303F);
  static const Color gradientMarkerEnd = Color(0xFF7A1A24);

  // Soft colored shadows used under gradient/primary surfaces
  static const Color shadowButton = Color.fromRGBO(140, 31, 43, 0.24);
  static const Color shadowCard = Color.fromRGBO(43, 20, 20, 0.06);
  static const Color shadowHero = Color.fromRGBO(92, 17, 25, 0.28);
  static const Color shadowDark = Color.fromRGBO(58, 15, 20, 0.24);

  // Redesign accent tokens (Home/Profile/Notifications/Settings editorial
  // surfaces) — deliberately separate from the flat status-color system
  // above, which the not-yet-redesigned screens (Requests, Donor details)
  // still use. The prototype uses distinct near-duplicate shades for these
  // two systems on purpose; don't collapse them into one.
  static const Color textPrimaryWarm = Color(0xFF241416);
  static const Color warmPageBackground = Color(0xFFFBF7F1);
  static const Color cardBorderWarm = Color(0xFFEEE8DF);
  static const Color dividerWarm = Color(0xFFF3EFE7);
  static const Color textMutedWarm = Color(0xFFB0A996);
  static const Color chevronMuted = Color(0xFFC9BFAF);

  static const Color warmAmberBg = Color(0xFFFBEFD9);
  static const Color warmAmberBorder = Color(0xFFF0E2C4);
  static const Color warmAmberText = Color(0xFF96590A);
  static const Color warmAmberIconTint = Color(0xFFF3E8D3);

  static const Color warmGreenBg = Color(0xFFE3F0DE);
  static const Color warmGreenBorder = Color(0xFFE3EEDC);
  static const Color warmGreenText = Color(0xFF2F6B3A);

  // Ember gradient — the dark red-to-black field used for the two "emotional
  // peak" moments (Onboarding page 1 "Brand", and Matched/donor-found): from
  // Product & Onboarding Art Direction, ~172deg #7E1C26 -> #270B0F -> #160809.
  static const Color gradientEmberStart = Color(0xFF7E1C26);
  static const Color gradientEmberMid = Color(0xFF270B0F);
  static const Color gradientEmberEnd = Color(0xFF160809);
}
