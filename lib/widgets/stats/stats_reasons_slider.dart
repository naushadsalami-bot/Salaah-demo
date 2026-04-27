import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shahada_app_getx/controllers/home_controller.dart';

class StatsReasonsSlider extends StatelessWidget {
  final String selectedPrayer;

  const StatsReasonsSlider({super.key, required this.selectedPrayer});

  final List<String> prayerNames = const [
    'Fajr',
    'Dhuhr',
    'Asar',
    'Maghrib',
    'Isha',
  ];
  final Color bgGrey = const Color(0xFFEBEBEB);
  final Color darkGreenBg = const Color(0xFF0D3B2E);

  HomeController get homeController => Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    if (selectedPrayer == 'All') {
      return Obx(() {
        // ✅ Pehle check karo kaunse pages mein reasons hain
        final pages = <Widget>[];

        final latePage = _buildReasonPage(
          context,
          "Praying Salah Late",
          PrayerStatus.late,
        );
        final missedPage = _buildReasonPage(
          context,
          "Missing Salah",
          PrayerStatus.missed,
        );
        final excusedPage = _buildReasonPage(
          context,
          "Praying On Time",
          PrayerStatus.excused,
        );

        if (_hasReasons(PrayerStatus.late)) pages.add(latePage);
        if (_hasReasons(PrayerStatus.missed)) pages.add(missedPage);
        if (_hasReasons(PrayerStatus.excused)) pages.add(excusedPage);

        // ✅ Agar koi bhi page nahi toh kuch show mat karo
        if (pages.isEmpty) return const SizedBox.shrink();

        return SizedBox(height: 145, child: PageView(children: pages));
      });
    } else {
      return Obx(() {
        // ✅ Single prayer mode mein bhi check karo
        if (!_hasSingleReasons()) return const SizedBox.shrink();
        return SizedBox(height: 145, child: _buildReasonPageSingle(context));
      });
    }
  }

  // ✅ Helper: All mode ke liye check
  bool _hasReasons(PrayerStatus filter) {
    bool found = false;
    homeController.notes.forEach((date, prayersMap) {
      final dayStatuses = homeController.days[date];
      if (dayStatuses != null) {
        prayersMap.forEach((key, reason) {
          int pIdx = prayerNames.indexOf(key.toString());
          if (pIdx != -1 &&
              dayStatuses[pIdx] == filter &&
              reason.trim().isNotEmpty) {
            found = true;
          }
        });
      }
    });
    return found;
  }

  // ✅ Helper: Single prayer mode ke liye check
  bool _hasSingleReasons() {
    final pIdx = prayerNames.indexOf(selectedPrayer);
    if (pIdx == -1) return false;
    bool found = false;
    homeController.notes.forEach((date, prayersMap) {
      final dayStatuses = homeController.days[date];
      if (dayStatuses != null && dayStatuses.length > pIdx) {
        final reason = prayersMap[selectedPrayer];
        if (reason != null && reason.trim().isNotEmpty) {
          found = true;
        }
      }
    });
    return found;
  }

  Widget _buildReasonPage(
    BuildContext context,
    String title,
    PrayerStatus filter,
  ) {
    return Obx(() {
      Map<String, int> reasonCounts = {};
      int totalFilterCount = 0;

      homeController.notes.forEach((date, prayersMap) {
        final dayStatuses = homeController.days[date];
        if (dayStatuses != null) {
          prayersMap.forEach((key, reason) {
            int pIdx = prayerNames.indexOf(key.toString());
            if (pIdx != -1 &&
                dayStatuses[pIdx] == filter &&
                reason.trim().isNotEmpty) {
              reasonCounts[reason] = (reasonCounts[reason] ?? 0) + 1;
              totalFilterCount++;
            }
          });
        }
      });

      return _buildSliderContent(
        context,
        title,
        reasonCounts,
        totalFilterCount,
      );
    });
  }

  Widget _buildReasonPageSingle(BuildContext context) {
    return Obx(() {
      Map<String, int> reasonCounts = {};
      int totalFilterCount = 0;
      final pIdx = prayerNames.indexOf(selectedPrayer);
      if (pIdx == -1)
        return _buildSliderContent(context, selectedPrayer, {}, 0);

      homeController.notes.forEach((date, prayersMap) {
        final dayStatuses = homeController.days[date];
        if (dayStatuses != null && dayStatuses.length > pIdx) {
          final reason = prayersMap[selectedPrayer];
          if (reason != null && reason.trim().isNotEmpty) {
            reasonCounts[reason] = (reasonCounts[reason] ?? 0) + 1;
            totalFilterCount++;
          }
        }
      });

      return _buildSliderContent(
        context,
        selectedPrayer,
        reasonCounts,
        totalFilterCount,
      );
    });
  }

  Widget _buildSliderContent(
    BuildContext context,
    String title,
    Map<String, int> reasonCounts,
    int totalFilterCount,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    var sorted = reasonCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff111F2F) : bgGrey,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Top Reasons For $title",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const Spacer(),
          ...sorted.take(2).toList().asMap().entries.map((entry) {
            final idx = entry.key;
            final e = entry.value;
            double pct = totalFilterCount > 0 ? e.value / totalFilterCount : 0;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${idx + 1}. ${e.key}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "${(pct * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(
                        color: Color(0xff1E73BE),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: pct,
                    color: const Color(0xFF2F80ED),
                    backgroundColor: isDark ? Colors.white24 : Colors.white,
                    minHeight: 7,
                  ),
                ),
                const SizedBox(height: 5),
              ],
            );
          }),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "$totalFilterCount times total",
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
