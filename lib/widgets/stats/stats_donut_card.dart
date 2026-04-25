import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shahada_app_getx/controllers/home_controller.dart';

class StatsDonutCard extends StatefulWidget {
  final String selectedPrayer;
  const StatsDonutCard({super.key, required this.selectedPrayer});

  @override
  State<StatsDonutCard> createState() => _StatsDonutCardState();
}

class _StatsDonutCardState extends State<StatsDonutCard> {
  bool showPercentage = false;

  final Color colorJamaah = const Color(0xFF67AC82);
  final Color colorOnTime = const Color(0xFF5D3E76);
  final Color colorLate = const Color(0xFF8D472E);
  final Color colorMissed = const Color(0xFFA12C2C);

  HomeController get homeController => Get.find<HomeController>();

  List<int> _getCounts() {
    final allDays = homeController.days;
    final prayerNames = ['Fajr', 'Dhuhr', 'Asar', 'Maghrib', 'Isha'];

    if (widget.selectedPrayer == 'All') {
      final allData = allDays.values.expand((p) => p).toList();
      return [
        allData.where((s) => s == PrayerStatus.prayed).length,
        allData.where((s) => s == PrayerStatus.excused).length,
        allData.where((s) => s == PrayerStatus.late).length,
        allData.where((s) => s == PrayerStatus.missed).length,
      ];
    } else {
      final pIdx = prayerNames.indexOf(widget.selectedPrayer);
      if (pIdx == -1) return [0, 0, 0, 0];
      int prayed = 0, excused = 0, late = 0, missed = 0;
      for (final dayStatuses in allDays.values) {
        if (dayStatuses.length > pIdx) {
          switch (dayStatuses[pIdx]) {
            case PrayerStatus.prayed:
              prayed++;
              break;
            case PrayerStatus.excused:
              excused++;
              break;
            case PrayerStatus.late:
              late++;
              break;
            case PrayerStatus.missed:
              missed++;
              break;
            default:
              break;
          }
        }
      }
      return [prayed, excused, late, missed];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      final counts = _getCounts();
      final total = counts.fold(0, (s, e) => s + e);
      final colors = [colorJamaah, colorOnTime, colorLate, colorMissed];
      final labels = ['In jamaah', 'On time', 'Late', 'Missed'];

      return GestureDetector(
        onTap: () => setState(() => showPercentage = !showPercentage),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111F2F) : const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(
                  painter: MultiDonutPainter(
                    counts: counts,
                    colors: colors,
                    total: total,
                    showPercentage: showPercentage,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  4,
                  (i) => _legendRow(colors[i], labels[i]),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ✅ SQUARE Legend Icon
  Widget _legendRow(Color c, String t) => Row(
    children: [
      Container(
        width: 12, // Same width
        height: 12, // Same height = Square
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(3), // Slight round corners
        ),
      ),
      const SizedBox(width: 10),
      Text(
        t,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ],
  );
}

class MultiDonutPainter extends CustomPainter {
  final List<int> counts;
  final List<Color> colors;
  final int total;
  final bool showPercentage;

  MultiDonutPainter({
    required this.counts,
    required this.colors,
    required this.total,
    required this.showPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeW = 18;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width / 2) - (strokeW / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    if (total == 0) {
      paint.color = Colors.grey.shade300;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    double startAngle = -math.pi / 2;

    for (int i = 0; i < counts.length; i++) {
      if (counts[i] == 0) continue;

      final double sweepAngle = (counts[i] / total) * 2 * math.pi;
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      // Number inside circle logic
      final double midAngle = startAngle + sweepAngle / 2;
      final double labelRadius = radius - 24;

      final Offset labelPos = Offset(
        center.dx + math.cos(midAngle) * labelRadius,
        center.dy + math.sin(midAngle) * labelRadius,
      );

      final String labelText = showPercentage
          ? '${(counts[i] / total * 100).toStringAsFixed(0)}%'
          : '${counts[i]}';

      final tp = TextPainter(
        text: TextSpan(
          text: labelText,
          style: TextStyle(
            color: colors[i],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(labelPos.dx - tp.width / 2, labelPos.dy - tp.height / 2),
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant MultiDonutPainter old) => true;
}

class SinglePrayerDonutPainter extends CustomPainter {
  final List<int> counts;
  final List<Color> colors;
  SinglePrayerDonutPainter({required this.counts, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeW = 18;
    final double radius = (size.width / 2) - (strokeW / 2);
    final Offset center = Offset(size.width / 2, size.height / 2);
    final int total = counts.fold(0, (sum, item) => sum + item);

    if (total == 0) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.grey.shade300
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
      return;
    }

    double startAngle = -math.pi / 2;
    for (int i = 0; i < counts.length; i++) {
      if (counts[i] == 0) continue;
      final sweep = (counts[i] / total) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) => true;
}
