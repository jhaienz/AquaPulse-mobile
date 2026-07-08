import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme.dart';

/// Arc gauge for mesh health. 270° sweep with a gap at the bottom; the value
/// arc is colored green/amber/red by how healthy the percentage is.
class ArcGauge extends StatelessWidget {
  final int percent; // 0..100
  final String label;
  const ArcGauge({super.key, required this.percent, required this.label});

  Color get _color => percent >= 80
      ? AppColors.normal
      : percent >= 50
          ? AppColors.warning
          : AppColors.critical;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 130,
      child: CustomPaint(
        painter: _GaugePainter(percent / 100, _color),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$percent%',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(label,
                  style: const TextStyle(fontSize: 10, letterSpacing: 1, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double fraction; // 0..1
  final Color color;
  _GaugePainter(this.fraction, this.color);

  static const _start = 0.75 * math.pi; // 135°
  static const _sweep = 1.5 * math.pi; // 270°

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: math.min(size.width, size.height) / 2 - 8,
    );
    final track = Paint()
      ..color = AppColors.surfaceAlt
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final value = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, _start, _sweep, false, track);
    canvas.drawArc(rect, _start, _sweep * fraction.clamp(0, 1), false, value);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.fraction != fraction || old.color != color;
}
