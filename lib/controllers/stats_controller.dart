import 'package:get/get.dart';

class StatsController extends GetxController {
  // Selected prayer
  final selectedPrayer = 'All'.obs;

  // Calendar
  final currentMonth = DateTime(2026, 1).obs;
  final selectedDay = 0.obs;

  void selectPrayer(String prayer) {
    selectedPrayer.value = prayer;
  }

  void selectDay(int day) {
    selectedDay.value = day;
  }

  void nextMonth() {
    currentMonth.value = DateTime(
      currentMonth.value.year,
      currentMonth.value.month + 1,
    );
  }

  void prevMonth() {
    currentMonth.value = DateTime(
      currentMonth.value.year,
      currentMonth.value.month - 1,
    );
  }

  String monthName(int m) {
    const months = [
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
    return months[m - 1];
  }
}
