import 'package:flutter/material.dart';

import '../models/forecast.dart';
import '../theme.dart';

/// DO trend chart for the Forecast card. Observed history is a solid line with
/// a soft fill; the projection is dashed; the species threshold is a dashed
/// horizontal line; "Now" is a faint vertical marker.
///
/// CustomPaint instead of a chart package — the shape is simple and this keeps
/// the dependency list empty (ponytail: fl_chart if we ever need axes/zoom).
class ForecastChart extends StatelessWidget {
  final Forecast forecast;
  const ForecastChart(this.forecast, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: CustomPaint(
        painter: _ForecastPainter(forecast),
        size: Size.infinite,
      ),
    );
  }
}

class _ForecastPainter extends CustomPainter {
  final Forecast f;
  _ForecastPainter(this.f);

  @override
  void paint(Canvas canvas, Size size) {
    final pts = f.curve;
    if (pts.isEmpty) return;

    const padL = 22.0, padR = 8.0, padT = 8.0, padB = 18.0;
    final plot = Rect.fromLTRB(padL, padT, size.width - padR, size.height - padB);

    final minT = pts.first.time.millisecondsSinceEpoch.toDouble();
    final maxT = pts.last.time.millisecondsSinceEpoch.toDouble();
    final values = pts.map((p) => p.doMgL).toList()..add(f.thresholdMgL);
    final minV = (values.reduce((a, b) => a < b ? a : b) - 0.5);
    final maxV = (values.reduce((a, b) => a > b ? a : b) + 0.5);

    Offset toPx(DateTime t, double v) {
      final x = plot.left +
          (t.millisecondsSinceEpoch - minT) / (maxT - minT) * plot.width;
      final y = plot.bottom - (v - minV) / (maxV - minV) * plot.height;
      return Offset(x, y);
    }

    // Y-axis min/max labels.
    _label(canvas, minV.toStringAsFixed(0), Offset(0, plot.bottom - 6));
    _label(canvas, maxV.toStringAsFixed(0), Offset(0, plot.top - 2));

    // Threshold line (dashed, amber).
    final thY = toPx(pts.first.time, f.thresholdMgL).dy;
    _dashedLine(canvas, Offset(plot.left, thY), Offset(plot.right, thY),
        Paint()..color = AppColors.warning.withValues(alpha: 0.7)..strokeWidth = 1);

    final observed = pts.where((p) => !p.projected).toList();
    final projected = pts.where((p) => p.projected).toList();

    // Fill under observed.
    if (observed.length >= 2) {
      final fill = Path()..moveTo(toPx(observed.first.time, observed.first.doMgL).dx, plot.bottom);
      for (final p in observed) {
        final o = toPx(p.time, p.doMgL);
        fill.lineTo(o.dx, o.dy);
      }
      fill.lineTo(toPx(observed.last.time, observed.last.doMgL).dx, plot.bottom);
      fill.close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.normal.withValues(alpha: 0.35), AppColors.normal.withValues(alpha: 0.0)],
          ).createShader(plot),
      );
    }

    // Observed line (solid green).
    _line(canvas, observed.map((p) => toPx(p.time, p.doMgL)).toList(),
        Paint()..color = AppColors.normal..strokeWidth = 2..style = PaintingStyle.stroke);

    // Projection (dashed red), joined to last observed point.
    final projPts = [
      if (observed.isNotEmpty) toPx(observed.last.time, observed.last.doMgL),
      ...projected.map((p) => toPx(p.time, p.doMgL)),
    ];
    for (var i = 0; i < projPts.length - 1; i++) {
      _dashedLine(canvas, projPts[i], projPts[i + 1],
          Paint()..color = AppColors.critical..strokeWidth = 2);
    }

    // "Now" marker at the observed/projected boundary.
    if (observed.isNotEmpty) {
      final nx = toPx(observed.last.time, observed.last.doMgL).dx;
      _dashedLine(canvas, Offset(nx, plot.top), Offset(nx, plot.bottom),
          Paint()..color = AppColors.textSecondary.withValues(alpha: 0.4)..strokeWidth = 1);
      _label(canvas, 'Now', Offset(nx - 8, plot.bottom + 3));
    }
  }

  void _line(Canvas c, List<Offset> pts, Paint p) {
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final o in pts.skip(1)) {
      path.lineTo(o.dx, o.dy);
    }
    c.drawPath(path, p);
  }

  void _dashedLine(Canvas c, Offset a, Offset b, Paint p) {
    const dash = 4.0, gap = 3.0;
    final total = (b - a).distance;
    final dir = (b - a) / total;
    var d = 0.0;
    while (d < total) {
      final start = a + dir * d;
      final end = a + dir * (d + dash).clamp(0, total);
      c.drawLine(start, end, p);
      d += dash + gap;
    }
  }

  void _label(Canvas c, String text, Offset at) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, at);
  }

  @override
  bool shouldRepaint(covariant _ForecastPainter old) => old.f != f;
}
