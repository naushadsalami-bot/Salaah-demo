import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shahada_app_getx/controllers/home_controller.dart';

class StatsCalendarCard extends StatelessWidget {
  final String selectedPrayer;
  final DateTime currentMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<int> onDayTap;

  const StatsCalendarCard({
    super.key,
    required this.selectedPrayer,
    required this.currentMonth,
    required this.onMonthChanged,
    required this.onDayTap,
  });

  final List<String> prayerNames = const [
    'Fajr',
    'Dhuhr',
    'Asar',
    'Maghrib',
    'Isha',
  ];
  final Color colorJamaah = const Color(0xFF67AC82);
  final Color colorOnTime = const Color(0xFF5D3E76);
  final Color colorLate = const Color(0xFF8D472E);
  final Color colorMissed = const Color(0xFFA12C2C);
  final Color colorNoData = const Color(0xFFCCCCCC); // grey ring for no data
  final Color bgGrey = const Color(0xFFEBEBEB);

  HomeController get homeController => Get.find<HomeController>();

  String _monthName(int m) => [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][m - 1];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int daysInMonth = DateUtils.getDaysInMonth(
      currentMonth.year,
      currentMonth.month,
    );
    int startWeekday =
        DateTime(currentMonth.year, currentMonth.month, 1).weekday - 1;

    DateTime now = DateTime.now();
    String todayPrefix =
        "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year.toString().substring(2)}";

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111F2F) : const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // ── Header Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_monthName(currentMonth.month)} ${currentMonth.year}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B3A2D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () => onMonthChanged(
                        DateTime(currentMonth.year, currentMonth.month - 1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3D2E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      onPressed: () => onMonthChanged(
                        DateTime(currentMonth.year, currentMonth.month + 1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Weekday Headers ──
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map(
                (e) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),

          // ── Days Grid ──
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: startWeekday + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
            ),
            itemBuilder: (context, index) {
              if (index < startWeekday) return const SizedBox();
              int day = index - startWeekday + 1;

              String formattedDay = day.toString().padLeft(2, '0');
              String formattedMonth = currentMonth.month.toString().padLeft(
                2,
                '0',
              );
              String formattedYear = currentMonth.year.toString().substring(2);
              String searchPrefix =
                  "$formattedDay.$formattedMonth.$formattedYear";

              bool isToday = searchPrefix == todayPrefix;

              // future date check
              final cellDate = DateTime(
                currentMonth.year,
                currentMonth.month,
                day,
              );
              final isFuture = cellDate.isAfter(DateTime.now());

              return Obx(() {
                String? matchedKey = homeController.days.keys
                    .toList()
                    .firstWhereOrNull((k) => k.startsWith(searchPrefix));

                final dayData = matchedKey != null
                    ? homeController.days[matchedKey]
                    : null;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onDayTap(day),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CustomPaint(
                            painter: FilteredSegmentPainter(
                              dayData: dayData ?? [],
                              isToday: isToday,
                              isFuture: isFuture,
                              selectedPrayer: selectedPrayer,
                              prayerNames: prayerNames,
                              colorJamaah: colorJamaah,
                              colorOnTime: colorOnTime,
                              colorLate: colorLate,
                              colorMissed: colorMissed,
                              colorNoData: colorNoData,
                            ),
                          ),
                        ),
                        Text(
                          '$day',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}

class FilteredSegmentPainter extends CustomPainter {
  final List<dynamic> dayData;
  final bool isToday;
  final bool isFuture;
  final String selectedPrayer;
  final List<String> prayerNames;
  final Color colorJamaah, colorOnTime, colorLate, colorMissed, colorNoData;

  FilteredSegmentPainter({
    required this.dayData,
    required this.isToday,
    required this.isFuture,
    required this.selectedPrayer,
    required this.prayerNames,
    required this.colorJamaah,
    required this.colorOnTime,
    required this.colorLate,
    required this.colorMissed,
    required this.colorNoData,
  });

  Color _statusColor(dynamic s) {
    // future dates → koi ring nahi
    if (isFuture) return Colors.transparent;

    if (s == null || s.toString().contains('none')) {
      // past ya today mein data nahi → grey ring
      return const Color(0xFFCCCCCC);
    }
    String status = s.toString().toLowerCase();
    if (status.contains('prayed')) return colorJamaah;
    if (status.contains('excused')) return colorOnTime;
    if (status.contains('late')) return colorLate;
    if (status.contains('missed')) return colorMissed;
    return const Color(0xFFCCCCCC);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (selectedPrayer == 'All') {
      double spacing = 0.4;
      double segmentSweep = (2 * pi / 5) - spacing;

      for (int i = 0; i < 5; i++) {
        dynamic s = (i < dayData.length) ? dayData[i] : null;
        paint.color = _statusColor(s);

        if (paint.color != Colors.transparent) {
          double startAngle = (i * 2 * pi / 5) - (pi / 2) + (spacing / 2);
          canvas.drawArc(rect, startAngle, segmentSweep, false, paint);
        }
      }
    } else {
      int pIdx = prayerNames.indexOf(selectedPrayer);
      dynamic s = (pIdx != -1 && pIdx < dayData.length) ? dayData[pIdx] : null;
      paint.color = _statusColor(s);
      if (paint.color != Colors.transparent) {
        canvas.drawArc(rect, -pi / 2, 2 * pi, false, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
