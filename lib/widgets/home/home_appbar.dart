import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shahada_app_getx/controllers/home_controller.dart';
import 'home_missed_sheet.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;
  final bool isDark;

  const HomeAppBar({super.key, required this.controller, required this.isDark});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: isDark ? Colors.black : Colors.white,
      elevation: isDark ? 0 : 1,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      title: Text(
        'Home',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        /// MISSED SALAH CIRCLE
        Obx(() {
          final count = controller.missedSalahs.length;
          if (count == 0) return const SizedBox.shrink();

          return GestureDetector(
            onTap: () {
              if (!controller.hasSeenMissedHint.value) {
                _showMissedHint(context, controller);
              } else {
                showMissedSalahSheet(context, controller);
              }
            },
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),

        const SizedBox(width: 8),

        /// STREAK ICON (Badi Image aur Uppar Text)
        Obx(() {
          final streak = controller.currentStreak.value;
          return GestureDetector(
            onTap: () => _showStreakInfoDialog(context, controller),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Fire Image (Size thoda bada kiya 28 -> 32)
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      isDark ? Colors.white : Colors.black,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      "images/Group-1.png",
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // 2. Streak Number (Thoda uppar shift kiya aur font bada kiya)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 3,
                    ), // 4 se kam karke 2 kiya taaki uppar dikhe
                    child: Text(
                      '$streak',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 13, // FontSize 11 se 13 kiya
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showMissedHint(BuildContext context, HomeController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tap this circle to see all your missed salah and complete them',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  controller.markMissedHintSeen();
                  Get.back();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStreakInfoDialog(BuildContext context, HomeController controller) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Streaks 🔥'),
        content: Text(
          'Current Streak: ${controller.currentStreak.value} days\n\nMark all 5 prayers to increase your streak!',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Ok')),
        ],
      ),
    );
  }
}
