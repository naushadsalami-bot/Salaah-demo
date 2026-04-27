import 'package:flutter/material.dart';
import 'package:shahada_app_getx/controllers/home_controller.dart';
import 'package:shahada_app_getx/home_screen.dart';
import 'home_prayer_sheet.dart';

class HomeDayRow extends StatelessWidget {
  final HomeController controller;
  final String dayKey;
  final List<PrayerStatus> prayers;
  final bool isDark;

  const HomeDayRow({
    super.key,
    required this.controller,
    required this.dayKey,
    required this.prayers,
    required this.isDark,
  });

  Color _statusColor(PrayerStatus status) {
    switch (status) {
      case PrayerStatus.prayed:
        return Color(0xff5FAE81);
      case PrayerStatus.excused:
        return Colors.purple;
      case PrayerStatus.late:
        return Colors.brown;
      case PrayerStatus.missed:
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final parts = dayKey.split(' ');
    final dateStr = parts[0];
    final dayLabel = parts[1];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // DATE
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateStr, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 2),
            Text(
              dayLabel,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: dayLabel == 'Today' ? Color(0xff5FAE81) : null,
              ),
            ),
          ],
        ),

        const Spacer(),

        // PRAYERS — same width as header columns
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return SizedBox(
              width: kPrayerColWidth,
              child: Center(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => showPrayerSheet(
                    context,
                    controller,
                    dayKey,
                    index,
                    isEdit: false,
                    isView: prayers[index] != PrayerStatus.none, // ✅ yahi badla
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: prayers[index] == PrayerStatus.none
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? Colors.white38 : Colors.black26,
                            ),
                          )
                        : Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: _statusColor(prayers[index]),
                            ),
                          ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
