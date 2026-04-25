import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shahada_app_getx/controllers/home_controller.dart';
import 'package:shahada_app_getx/widgets/app_bottom_navigation.dart';
import 'package:shahada_app_getx/widgets/home/home_appbar.dart';
import 'package:shahada_app_getx/widgets/home/home_day_row.dart';
import 'package:shahada_app_getx/widgets/home/home_prayer_sheet.dart'
    as prayerSheet;

const double kPrayerColWidth = 44.0;
const List<String> kPrayerNames = ['Fajr', 'Dhuhr', 'Asar', 'Maghr', 'Isha'];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showEditPopup = false;

  void _showNoSalahDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'No Salah Selected',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'You haven\'t recorded any Salah yet. Please mark a Salah first to edit it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatShortDate(String dateStr) {
    try {
      final parts = dateStr.split('.');
      final day = parts[0];
      final month = int.parse(parts[1]);
      final year = '20${parts[2]}';
      const monthNames = [
        '',
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
      ];
      return '$day-${monthNames[month]}-$year';
    } catch (_) {
      return dateStr;
    }
  }

  void _showSelectPrayerSheet(HomeController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade200,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Text(
                    'Select a recorded Salah to edit:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Obx(
                      () => ListView(
                        controller: scrollController,
                        children: controller.days.entries.map((entry) {
                          final parts = entry.key.split(' ');
                          final dateStr = parts[0];
                          final dayLabel = parts[1];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                // '$dayLabel ($dateStr)',
                                '$dayLabel (${_formatShortDate(dateStr)})',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: dayLabel == 'Today'
                                      ? Color(0xff5FAE81)
                                      : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(5, (i) {
                                  final status = entry.value[i];
                                  final isClickable =
                                      status != PrayerStatus.none;

                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: isClickable
                                          ? () {
                                              Get.back();
                                              prayerSheet.showPrayerSheet(
                                                context,
                                                controller,
                                                entry.key,
                                                i,
                                                isEdit: true,
                                              );
                                            }
                                          : () {
                                              Get.snackbar(
                                                'Notice',
                                                'Please mark this Salah on Home screen first.',
                                                snackPosition:
                                                    SnackPosition.BOTTOM,
                                                duration: const Duration(
                                                  seconds: 1,
                                                ),
                                              );
                                            },
                                      child: Opacity(
                                        opacity: isClickable ? 1.0 : 0.3,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            right: 4,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isClickable
                                                ? Colors.teal.shade50
                                                : Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: isClickable
                                                ? Border.all(
                                                    color: Colors.teal.shade200,
                                                  )
                                                : null,
                                          ),
                                          child: Center(
                                            child: Text(
                                              kPrayerNames[i],
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: isClickable
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isClickable
                                                    ? Colors.teal.shade700
                                                    : Colors.black38,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: HomeAppBar(controller: controller, isDark: isDark),
      body: Stack(
        children: [
          Obx(
            () => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => _showEditPopup = !_showEditPopup),
                        child: Icon(
                          Icons.edit_square,
                          size: 20,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      ...List.generate(kPrayerNames.length, (i) {
                        return SizedBox(
                          width: kPrayerColWidth,
                          child: Center(
                            child: Text(
                              kPrayerNames[i],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...controller.days.entries.map(
                    (entry) => Column(
                      children: [
                        HomeDayRow(
                          controller: controller,
                          dayKey: entry.key,
                          prayers: entry.value,
                          isDark: isDark,
                        ),
                        const Divider(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dark pill popup logic with validation
          if (_showEditPopup)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: 100,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2E2E),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _showEditPopup = false),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 20, color: Colors.white24),
                      GestureDetector(
                        onTap: () {
                          setState(() => _showEditPopup = false);

                          // Check if any record exists to enable edit
                          final hasAnyRecord = controller.days.values.any(
                            (prayers) =>
                                prayers.any((s) => s != PrayerStatus.none),
                          );

                          if (!hasAnyRecord) {
                            _showNoSalahDialog();
                          } else {
                            _showSelectPrayerSheet(controller);
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
