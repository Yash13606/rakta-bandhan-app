import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Initials avatar — gradient fill (Home header, standalone use on cream
/// backgrounds) or a translucent frosted-glass variant for sitting on top of
/// a gradient header (Profile, Donor details, Match contact).
class AvatarBadge extends StatelessWidget {
  final String initials;
  final double size;
  final double fontSize;
  final Color startColor;
  final Color endColor;
  final Color textColor;
  final bool translucent;

  const AvatarBadge({
    super.key,
    required this.initials,
    this.size = 46,
    double? fontSize,
    this.startColor = AppColors.gradientAvatarStart,
    this.endColor = AppColors.gradientAvatarEnd,
    this.textColor = AppColors.whiteTextOnPrimary,
    this.translucent = false,
  }) : fontSize = fontSize ?? size * 0.33;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: translucent
          ? BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.whiteTextOnPrimary.withValues(alpha: 0.14),
              border: Border.all(color: AppColors.whiteTextOnPrimary.withValues(alpha: 0.35), width: 2),
            )
          : BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [startColor, endColor]),
            ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }
}
