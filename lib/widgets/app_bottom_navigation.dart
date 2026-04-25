import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  void _onTap(int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Get.toNamed('/home');
        break;
      case 1:
        Get.toNamed('/stats');
        break;
      case 2:
        Get.toNamed('/settings');
        break;
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: _onTap,
      type: BottomNavigationBarType.fixed,

      // 🔥 background
      backgroundColor: isDark
          ? const Color(0xFF0E1412) // figma dark bg
          : Colors.white,

      // 🔥 selected item
      selectedItemColor: Color(0xff5FAE81),

      // 🔥 unselected item
      unselectedItemColor: isDark ? Colors.white54 : Colors.black54,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
