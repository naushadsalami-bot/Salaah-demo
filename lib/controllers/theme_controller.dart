import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AppTheme { light, dark, system }

class ThemeController extends GetxController {
  Rx<AppTheme> selectedTheme = AppTheme.system.obs;

  ThemeMode get themeMode {
    switch (selectedTheme.value) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
      default:
        return ThemeMode.system;
    }
  }

  bool get isDark {
    if (selectedTheme.value == AppTheme.system) {
      return Get.isDarkMode;
    }
    return selectedTheme.value == AppTheme.dark;
  }

  void changeTheme(AppTheme theme) {
    selectedTheme.value = theme;
    Get.changeThemeMode(themeMode); //  WHOLE APP UPDATE
  }
}
