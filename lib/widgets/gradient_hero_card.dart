import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Prototype's editorial gradient surface (hero card, profile/donor-details
/// headers, matching screen) — one shared implementation so the
/// gradient/ring/shadow treatment doesn't drift per screen.
class GradientHeroCard extends StatelessWidget {
  final Widget child;
  final Color startColor;
  final Color endColor;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final double? ringLeft;
  final double? ringTop;
  final double? ringRight;
  final double? ringBottom;
  final double ringSize;
  final bool showRing;
  final Color? shadowColor;

  const GradientHeroCard({
    super.key,
    required this.child,
    this.startColor = AppColors.gradientHeroStart,
    this.endColor = AppColors.gradientHeroEnd,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.borderRadius = BorderRadius.zero,
    this.padding = const EdgeInsets.all(20),
    this.ringRight = -30,
    this.ringBottom = -40,
    this.ringLeft,
    this.ringTop,
    this.ringSize = 140,
    this.showRing = true,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: gradientBegin,
          end: gradientEnd,
          colors: [startColor, endColor],
        ),
        borderRadius: borderRadius,
        boxShadow: shadowColor == null
            ? null
            : [BoxShadow(color: shadowColor!, blurRadius: 30, offset: const Offset(0, 16))],
      ),
      padding: padding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (showRing)
            Positioned(
              left: ringLeft,
              top: ringTop,
              right: ringRight,
              bottom: ringBottom,
              child: Opacity(
                opacity: 0.14,
                child: CustomPaint(size: Size(ringSize, ringSize), painter: _RingPainter()),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.whiteTextOnPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width / 2, paint);
    canvas.drawCircle(center, size.width / 2 * 0.68, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
