import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The droplet-shaped blood-group token — Visual Richness Proposal's
/// "Group token" device ("A group is never a rectangle again"). Shared by
/// every screen that shows a blood group so the shape/fill grammar never
/// forks: filled = solid colour (the need/self), tinted = pale fill on
/// primary text (a compatible/secondary group), outline = hollow (inactive,
/// expired, "cannot help").
///
/// Path traced from the design SVG's `viewBox="0 0 40 48"` droplet — a
/// pointed top flowing into a circular base — scaled to [size] wide by
/// size*1.2 tall.
class BloodGroupDroplet extends StatelessWidget {
  final String label;
  final double size;
  final bool filled;
  final Color color;
  final Color textColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final bool serif;

  /// Overrides the label text with an arbitrary icon/widget centered inside
  /// the droplet — the "donation confirmed" mark (droplet + check) uses
  /// this instead of a blood-group label.
  final Widget? centerIcon;

  const BloodGroupDroplet({
    super.key,
    required this.label,
    this.size = 40,
    this.filled = true,
    this.color = AppColors.primary,
    this.textColor = AppColors.whiteTextOnPrimary,
    this.fontSize,
    this.fontWeight = FontWeight.w700,
    this.serif = false,
    this.centerIcon,
  });

  @override
  Widget build(BuildContext context) {
    final height = size * 1.2;
    final resolvedFontSize = fontSize ?? size * 0.34;
    return SizedBox(
      width: size,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size(size, height), painter: _DropletPainter(color: color, filled: filled)),
          Padding(
            padding: EdgeInsets.only(top: height * 0.13),
            child: centerIcon ??
                Text(
                  label,
                  style: serif
                      ? AppTextStyles.display(fontSize: resolvedFontSize, color: textColor, fontWeight: fontWeight)
                      : TextStyle(fontSize: resolvedFontSize, fontWeight: fontWeight, color: textColor),
                ),
          ),
        ],
      ),
    );
  }
}

class _DropletPainter extends CustomPainter {
  final Color color;
  final bool filled;

  _DropletPainter({required this.color, required this.filled});

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 40;
    final sy = size.height / 48;
    final path = Path()
      ..moveTo(20 * sx, 2 * sy)
      ..cubicTo(28 * sx, 12.4 * sy, 35 * sx, 19.4 * sy, 35 * sx, 26.6 * sy)
      ..arcToPoint(
        Offset(5 * sx, 26.6 * sy),
        radius: Radius.elliptical(15 * sx, 15 * sy),
        clockwise: true,
        largeArc: true,
      )
      ..cubicTo(5 * sx, 19.4 * sy, 12 * sx, 12.4 * sy, 20 * sx, 2 * sy)
      ..close();

    final paint = Paint()..color = color;
    if (filled) {
      paint.style = PaintingStyle.fill;
    } else {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DropletPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.filled != filled;
}
