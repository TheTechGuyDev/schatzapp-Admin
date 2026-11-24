import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

class ChartSeries {
  const ChartSeries({
    required this.name,
    required this.color,
    required this.values,
    this.fill = false,
    this.dashed = false,
    this.secondary = false,
    this.format,
  });

  final String name;
  final Color color;
  final List<double> values;
  final bool fill;
  final bool dashed;

  /// Plotted against the right-hand axis (its own scale).
  final bool secondary;

  /// Value formatter for the tooltip and the axis this series uses.
  final String Function(double)? format;
}

/// Multi-series line chart: gridlines, optional area fill, dashed series,
/// an optional right axis and a hover tooltip.
class LineChart extends StatefulWidget {
  const LineChart({
    super.key,
    required this.series,
    required this.labels,
    this.height = 240,
    this.smooth = false,
  });

  final List<ChartSeries> series;
  final List<String> labels;
  final double height;
  final bool smooth;

  @override
  State<LineChart> createState() => _LineChartState();
}

double _niceMax(double v) {
  if (v <= 0) return 1;
  final mag = math.pow(10, (math.log(v) / math.ln10).floor()).toDouble();
  final n = v / mag;
  final nice = n <= 1
      ? 1
      : n <= 2
      ? 2
      : n <= 2.5
      ? 2.5
      : n <= 5
      ? 5
      : 10;
  return nice * mag;
}

class _LineChartState extends State<LineChart> {
  int? _hover;

  double _maxFor(bool secondary) {
    var m = 0.0;
    for (final s in widget.series.where((s) => s.secondary == secondary)) {
      for (final v in s.values) {
        m = math.max(m, v);
      }
    }
    return _niceMax(m);
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.series.first.values.length;
    final hasRight = widget.series.any((s) => s.secondary);
    const leftPad = 46.0;
    final rightPad = hasRight ? 40.0 : 6.0;
    const bottomPad = 26.0;
    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, c) {
          final plotW = c.maxWidth - leftPad - rightPad;
          double xAt(int i) =>
              leftPad + (count == 1 ? 0 : plotW * i / (count - 1));
          int indexAt(double dx) {
            final x = (dx - leftPad).clamp(0, plotW);
            return (x / plotW * (count - 1)).round();
          }

          return MouseRegion(
            onExit: (_) => setState(() => _hover = null),
            onHover: (e) {
              final i = indexAt(e.localPosition.dx);
              if (i != _hover) setState(() => _hover = i);
            },
            child: GestureDetector(
              onTapDown: (e) =>
                  setState(() => _hover = indexAt(e.localPosition.dx)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LinePainter(
                        series: widget.series,
                        labels: widget.labels,
                        maxLeft: _maxFor(false),
                        maxRight: hasRight ? _maxFor(true) : 1,
                        leftPad: leftPad,
                        rightPad: rightPad,
                        bottomPad: bottomPad,
                        hover: _hover,
                        smooth: widget.smooth,
                      ),
                    ),
                  ),
                  if (_hover != null)
                    Positioned(
                      left: (xAt(_hover!) + 14 + 180 > c.maxWidth)
                          ? xAt(_hover!) - 194
                          : xAt(_hover!) + 14,
                      top: 6,
                      child: IgnorePointer(child: _tooltip(_hover!)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tooltip(int i) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14111827),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.labels[i],
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          for (final s in widget.series)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: s.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      s.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    (s.format ?? compactNumber)(s.values[i]),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.series,
    required this.labels,
    required this.maxLeft,
    required this.maxRight,
    required this.leftPad,
    required this.rightPad,
    required this.bottomPad,
    required this.hover,
    required this.smooth,
  });

  final List<ChartSeries> series;
  final List<String> labels;
  final double maxLeft;
  final double maxRight;
  final double leftPad;
  final double rightPad;
  final double bottomPad;
  final int? hover;
  final bool smooth;

  int _divisions(double max) {
    final mag = math.pow(10, (math.log(max) / math.ln10).floor()).toDouble();
    final lead = (max / mag).round();
    return (lead == 2 || lead == 4) ? 4 : 5;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final plotW = size.width - leftPad - rightPad;
    final plotH = size.height - bottomPad;
    final count = series.first.values.length;
    double x(int i) => leftPad + (count == 1 ? 0 : plotW * i / (count - 1));
    double y(double v, double max) => plotH - (v / max) * (plotH - 8);

    final leftFmt =
        series
            .firstWhere((s) => !s.secondary, orElse: () => series.first)
            .format ??
        compactNumber;
    final rightSeries = series.where((s) => s.secondary).toList();
    final rightFmt = rightSeries.isEmpty
        ? compactNumber
        : (rightSeries.first.format ?? compactNumber);

    final divisions = _divisions(maxLeft);
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (var g = 0; g <= divisions; g++) {
      final gy = y(maxLeft * g / divisions, maxLeft);
      _dashedLine(
        canvas,
        Offset(leftPad, gy),
        Offset(size.width - rightPad, gy),
        grid,
        dash: 4,
        gap: 4,
      );
      _text(
        canvas,
        leftFmt(maxLeft * g / divisions),
        Offset(0, gy - 7),
        10.5,
        AppColors.textSecondary,
        width: leftPad - 8,
        align: TextAlign.right,
      );
      if (rightSeries.isNotEmpty) {
        _text(
          canvas,
          rightFmt(maxRight * g / divisions),
          Offset(size.width - rightPad + 6, gy - 7),
          10.5,
          AppColors.textSecondary,
          width: rightPad - 6,
        );
      }
    }

    final step = math.max(1, (count / math.max(1, plotW / 70)).ceil());
    for (var i = 0; i < count; i += step) {
      _text(
        canvas,
        labels[i],
        Offset(x(i) - 30, plotH + 9),
        10.5,
        AppColors.textSecondary,
        width: 60,
        align: TextAlign.center,
      );
    }

    for (final s in series) {
      final max = s.secondary ? maxRight : maxLeft;
      final pts = [
        for (var i = 0; i < count; i++) Offset(x(i), y(s.values[i], max)),
      ];
      final path = smooth ? _smooth(pts) : _straight(pts);
      if (s.fill) {
        final area = Path.from(path)
          ..lineTo(pts.last.dx, plotH)
          ..lineTo(pts.first.dx, plotH)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                s.color.withValues(alpha: 0.18),
                s.color.withValues(alpha: 0.0),
              ],
            ).createShader(Rect.fromLTWH(0, 0, size.width, plotH)),
        );
      }
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.dashed ? 1.8 : 2.4
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;
      if (s.dashed) {
        for (var i = 0; i < pts.length - 1; i++) {
          _dashedLine(canvas, pts[i], pts[i + 1], paint, dash: 6, gap: 5);
        }
        for (final p in pts) {
          canvas.drawCircle(p, 2.6, Paint()..color = s.color);
        }
      } else {
        canvas.drawPath(path, paint);
        if (!smooth) {
          for (final p in pts) {
            canvas.drawCircle(p, 3, Paint()..color = s.color);
          }
        }
      }
    }

    if (hover != null) {
      final hx = x(hover!);
      _dashedLine(
        canvas,
        Offset(hx, 4),
        Offset(hx, plotH),
        Paint()
          ..color = AppColors.textMuted
          ..strokeWidth = 1,
        dash: 3,
        gap: 3,
      );
      for (final s in series) {
        final p = Offset(
          hx,
          y(s.values[hover!], s.secondary ? maxRight : maxLeft),
        );
        canvas.drawCircle(p, 6, Paint()..color = Colors.white);
        canvas.drawCircle(
          p,
          6,
          Paint()
            ..color = s.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      }
    }
  }

  Path _straight(List<Offset> p) {
    final path = Path()..moveTo(p.first.dx, p.first.dy);
    for (final o in p.skip(1)) {
      path.lineTo(o.dx, o.dy);
    }
    return path;
  }

  Path _smooth(List<Offset> p) {
    final path = Path()..moveTo(p.first.dx, p.first.dy);
    for (var i = 0; i < p.length - 1; i++) {
      final p0 = i > 0 ? p[i - 1] : p[i];
      final p1 = p[i];
      final p2 = p[i + 1];
      final p3 = i + 2 < p.length ? p[i + 2] : p2;
      final c1 = p1 + (p2 - p0) / 6;
      final c2 = p2 - (p3 - p1) / 6;
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.hover != hover || old.series != series;
}

void _dashedLine(
  Canvas canvas,
  Offset a,
  Offset b,
  Paint paint, {
  double dash = 5,
  double gap = 4,
}) {
  final total = (b - a).distance;
  if (total == 0) return;
  final dir = (b - a) / total;
  var d = 0.0;
  while (d < total) {
    final end = math.min(d + dash, total);
    canvas.drawLine(a + dir * d, a + dir * end, paint);
    d = end + gap;
  }
}

/// Donut chart with a centred total.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.values,
    required this.colors,
    required this.centerTop,
    required this.centerBottom,
    this.size = 170,
    this.stroke = 22,
    this.gap = 0.025,
    this.fontSize = 22,
  });

  final List<double> values;
  final List<Color> colors;
  final String centerTop;
  final String centerBottom;
  final double size;
  final double stroke;
  final double gap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _DonutPainter(values, colors, stroke, gap),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerTop,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                centerBottom,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.values, this.colors, this.stroke, this.gap);
  final List<double> values;
  final List<Color> colors;
  final double stroke;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * math.pi;
      if (sweep <= 0) continue;
      canvas.drawArc(
        rect,
        start + gap / 2,
        math.max(0.001, sweep - gap),
        false,
        Paint()
          ..color = colors[i % colors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.values != values;
}

/// Tiny trend line used inside stat cards.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    required this.color,
    this.width = 84,
    this.height = 34,
  });

  final List<double> values;
  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(width, height),
    painter: _SparkPainter(values, color),
  );
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.color);
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final mn = values.reduce(math.min);
    final mx = values.reduce(math.max);
    final span = (mx - mn) == 0 ? 1 : mx - mn;
    final pts = [
      for (var i = 0; i < values.length; i++)
        Offset(
          size.width * i / (values.length - 1),
          size.height - 3 - (values[i] - mn) / span * (size.height - 6),
        ),
    ];
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      line.lineTo(p.dx, p.dy);
    }
    final area = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter old) => old.values != values;
}

void _text(
  Canvas canvas,
  String s,
  Offset at,
  double size,
  Color color, {
  double? width,
  TextAlign align = TextAlign.left,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: s,
      style: TextStyle(fontSize: size, color: color),
    ),
    textAlign: align,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: width ?? 0, maxWidth: width ?? double.infinity);
  tp.paint(canvas, at);
}

/// 12480 -> 12.5K, 48200000 -> 48.2M.
String compactNumber(double v) {
  final a = v.abs();
  String trim(double n) {
    final s = n.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  if (a >= 1e9) return '${trim(v / 1e9)}B';
  if (a >= 1e6) return '${trim(v / 1e6)}M';
  if (a >= 1e3) return '${trim(v / 1e3)}K';
  return trim(v);
}

/// 12480 -> 12,480
String groupDigits(num v) {
  final s = v.round().abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return (v < 0 ? '-' : '') + b.toString();
}
