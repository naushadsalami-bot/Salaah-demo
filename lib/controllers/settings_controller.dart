import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shahada_app_getx/controllers/home_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shahada_app_getx/Services/notification_service.dart';
import 'package:shahada_app_getx/controllers/theme_controller.dart';

class SettingsController extends GetxController {
  final TextEditingController reasonTextController = TextEditingController();
  final List<String> _defaultReasons = [
    'Alarm',
    'Appointment',
    'Caregiving',
    'Education',
    'Emergency',
    'Family/Friends',
    'Gaming',
    'Guests',
    'Health',
    'Leisure',
    'Other',
    'Shopping',
    'Sleep',
    'Sports',
    'Travel',
    'TV',
    'Work',
  ];

  RxList<String> reasons = <String>[].obs;
  RxString newReason = ''.obs;
  RxBool showMissedSalahCounter = true.obs;
  RxBool dailyNotification = false.obs;
  RxBool salahNotification = false.obs;
  RxString notificationTimeType = 'fixed'.obs;
  Rx<TimeOfDay> fixedTime = const TimeOfDay(hour: 21, minute: 0).obs;
  RxInt afterIshaMinutes = 60.obs;
  Rxn<DateTime> startDate = Rxn<DateTime>(DateTime(2026, 1, 8));
  Rx<AppTheme> selectedTheme = AppTheme.system.obs;

  @override
  void onInit() {
    reasons.assignAll(_defaultReasons);
    super.onInit();
    _loadSavedPrefs();
  }

  Future<void> _loadSavedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    dailyNotification.value = prefs.getBool('daily_notification_on') ?? false;
    final hour = prefs.getInt('notification_hour') ?? 21;
    final minute = prefs.getInt('notification_minute') ?? 0;
    fixedTime.value = TimeOfDay(hour: hour, minute: minute);

    final savedDate = prefs.getString('user_join_date');
    if (savedDate != null) {
      startDate.value = DateTime.parse(savedDate);
    }

    // ✅ Saved reasons load karo
    final savedReasons = prefs.getStringList('custom_reasons');
    if (savedReasons != null && savedReasons.isNotEmpty) {
      reasons.assignAll(savedReasons);
    } else {
      reasons.assignAll(_defaultReasons);
    }

    // ✅ HomeController tags sync karo
    _syncHomeControllerTags();
  }

  void _syncHomeControllerTags() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().updateTags(reasons.toList());
    }
  }

  Future<void> _saveReasons() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('custom_reasons', reasons.toList());
    _syncHomeControllerTags();
  }

  void toggleDailyNotification(bool value) async {
    dailyNotification.value = value;
    if (value) {
      await NotificationService.scheduleDailyAndSave(fixedTime.value);
    } else {
      await NotificationService.cancelAllAndSave();
    }
  }

  void setFixedTime(TimeOfDay time) async {
    fixedTime.value = time;
    notificationTimeType.value = 'fixed';
    if (dailyNotification.value) {
      await NotificationService.scheduleDailyAndSave(time);
    }
  }

  void toggleMissedSalah(bool value) => showMissedSalahCounter.value = value;
  void toggleSalahNotification(bool value) => salahNotification.value = value;
  void setNotificationTimeType(String type) =>
      notificationTimeType.value = type;
  void setAfterIshaMinutes(int minutes) => afterIshaMinutes.value = minutes;

  void changeStartDate(DateTime? date) async {
    startDate.value = date;
    final prefs = await SharedPreferences.getInstance();
    if (date == null) {
      await prefs.remove('user_join_date');
    } else {
      await prefs.setString('user_join_date', date.toIso8601String());
    }
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadData();
    }
  }

  void changeTheme(AppTheme theme) {
    selectedTheme.value = theme;
    Get.back();
  }

  // void addReason() {
  //   if (newReason.value.trim().isEmpty) return;
  //   reasons.add(newReason.value.trim());
  //   newReason.value = '';
  //   _saveReasons(); // ✅ save + sync
  // }
  void addReason() async {
    final text = newReason.value.trim();
    if (text.isEmpty) return;

    reasons.add(text);

    newReason.value = '';

    reasonTextController.clear(); 

    await _saveReasons();
  }

  void removeReason(String reason) {
    reasons.remove(reason);
    _saveReasons(); // ✅ save + sync
  }

  void resetReasons() {
    reasons.assignAll(_defaultReasons);
    _saveReasons(); // ✅ save + sync
  }
}
