import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// The "radius" richness device — a hairline running from a request's origin
/// dot to "You", carrying the real distance as its label. Used on Home's
/// live request card and Requests' open/matched rows so distance reads as
/// geometry, not just a string.
class DistanceConnector extends StatelessWidget {
  final String distanceLabel;
  final Color dotColor;
  final Color lineColor;

  const DistanceConnector({
    super.key,
    required this.distanceLabel,
    this.dotColor = AppColors.primary,
    this.lineColor = AppColors.dividerWarm,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(height: 1, color: lineColor),
              Align(
                alignment: const Alignment(-0.35, 0),
                child: Container(width: 5, height: 5, decoration: BoxDecoration(color: AppColors.chevronMuted, shape: BoxShape.circle)),
              ),
              Align(
                alignment: const Alignment(0.35, 0),
                child: Container(width: 5, height: 5, decoration: BoxDecoration(color: AppColors.chevronMuted, shape: BoxShape.circle)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 9),
        Text(distanceLabel, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimaryWarm)),
        const SizedBox(width: 9),
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(color: AppColors.primaryLightTint, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Text('You', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
      ],
    );
  }
}
