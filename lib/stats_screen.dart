import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shahada_app_getx/controllers/home_controller.dart';
import 'package:shahada_app_getx/widgets/app_bottom_navigation.dart';
import 'package:shahada_app_getx/widgets/stats/prayer_filter_bar.dart';
import 'package:shahada_app_getx/widgets/stats/stats_calendar_card.dart';
import 'package:shahada_app_getx/widgets/stats/stats_donut_card.dart';
import 'package:shahada_app_getx/widgets/stats/stats_reasons_slider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String selectedPrayer = 'All';
  late DateTime currentMonth;

  final prayers = ['All', 'Fajr', 'Dhuhr', 'Asar', 'Maghrib', 'Isha'];
  HomeController get homeController => Get.find<HomeController>();

  final Color darkGreenBg = const Color(0xFF0D3B2E);
  final Color accentGold = const Color(0xFFD6B25E);
  final Color bgGrey = const Color(0xFFEBEBEB);

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Stats',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              const SizedBox(height: 12),

              _streakCard(),

              const SizedBox(height: 12),
              PrayerFilterBar(
                prayers: prayers,
                selected: selectedPrayer,
                darkGreenBg: darkGreenBg,
                accentGold: accentGold,
                onSelected: (p) => setState(() => selectedPrayer = p),
              ),
              const SizedBox(height: 12),
              StatsDonutCard(selectedPrayer: selectedPrayer),
              const SizedBox(height: 12),
              StatsCalendarCard(
                selectedPrayer: selectedPrayer,
                currentMonth: currentMonth,
                onMonthChanged: (m) => setState(() => currentMonth = m),
                onDayTap: (day) => _openDayBottomSheet(day),
              ),
              const SizedBox(height: 12),
              StatsReasonsSlider(selectedPrayer: selectedPrayer),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _streakCard() => Obx(() {
    final streak = homeController.currentStreak.value;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2F80ED), Color(0xFF27AE60)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            "images/Vector.png",
            height: 50,
            errorBuilder: (c, e, s) =>
                const Icon(Icons.flash_on, color: Colors.white24),
          ),
          Column(
            children: [
              Text(
                '$streak Days',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Current Streak',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          Image.asset(
            "images/Vector (1).png",
            height: 50,
            errorBuilder: (c, e, s) =>
                const Icon(Icons.flash_on, color: Colors.white24),
          ),
        ],
      ),
    );
  });

  void _openDayBottomSheet(int day) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prayerNames = ['Fajr', 'Dhuhr', 'Asar', 'Maghrib', 'Isha'];

    String formattedDay = day.toString().padLeft(2, '0');
    String formattedMonth = currentMonth.month.toString().padLeft(2, '0');
    String formattedYear = currentMonth.year.toString().substring(2);
    String datePart = "$formattedDay.$formattedMonth.$formattedYear";

    String? matchedKey = homeController.days.keys.toList().firstWhereOrNull(
      (k) => k.startsWith(datePart),
    );
    final dayData = matchedKey != null ? homeController.days[matchedKey] : null;
    final dayNotes = matchedKey != null
        ? homeController.notes[matchedKey]
        : null;

    final Color colorJamaah = const Color(0xFF67AC82);
    final Color colorOnTime = const Color(0xFF5D3E76);
    final Color colorLate = const Color(0xFF0D3B2E);
    final Color colorMissed = const Color(0xFFA12C2C);

    List<int> indicesToShow;
    if (selectedPrayer == 'All') {
      indicesToShow = List.generate(5, (i) => i);
    } else {
      final idx = prayerNames.indexOf(selectedPrayer);
      indicesToShow = idx != -1 ? [idx] : List.generate(5, (i) => i);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: selectedPrayer == 'All'
            ? MediaQuery.of(context).size.height * 0.9
            : MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111F2F) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              "$day ${_monthName(currentMonth.month)} ${currentMonth.year}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: dayData == null
                  ? Center(
                      child: Text(
                        "No record for this day",
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: indicesToShow.length,
                      itemBuilder: (c, i) {
                        final pIdx = indicesToShow[i];
                        PrayerStatus s = dayData[pIdx];

                        String note =
                            (dayNotes != null &&
                                dayNotes.containsKey(prayerNames[pIdx]))
                            ? dayNotes[prayerNames[pIdx]]!
                            : "";

                        Color col = s == PrayerStatus.prayed
                            ? colorJamaah
                            : s == PrayerStatus.late
                            ? colorLate
                            : s == PrayerStatus.missed
                            ? colorMissed
                            : s == PrayerStatus.excused
                            ? colorOnTime
                            : Colors.grey;

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 2.5,
                                    height: 25,
                                    color: isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade300,
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prayerNames[pIdx],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        Text(
                                          note.isEmpty
                                              ? "Notes: None"
                                              : "Notes: $note",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: s == PrayerStatus.none
                                          ? Colors.grey.shade700
                                          : col,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      s == PrayerStatus.none
                                          ? "No Data"
                                          : s.name.capitalizeFirst!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              thickness: 1,
                              height: 1,
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300,
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

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
}
