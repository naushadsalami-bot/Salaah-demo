import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shahada_app_getx/Services/api_service.dart';

enum PrayerStatus { none, prayed, excused, late, missed }

class MissedSalah {
  final String dayKey;
  final int prayerIndex;
  final String prayerName;
  MissedSalah({
    required this.dayKey,
    required this.prayerIndex,
    required this.prayerName,
  });
}

class HomeController extends GetxController {
  var days = <String, List<PrayerStatus>>{}.obs;
  var notes = <String, Map<String, String>>{}.obs;
  var currentStreak = 0.obs;

  final notesController = TextEditingController();
  final selectedTags = <String>{}.obs;
  var selectedStatus = PrayerStatus.none.obs;
  final missedSalahs = <MissedSalah>[].obs;
  final hasSeenMissedHint = false.obs;

  RxList<String> tags = <String>[
    'Alarm',
    'Appointment',
    'Caregiving',
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
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadTagsFromPrefs(); // ✅ app open hote hi saved tags load
    loadData();
  }

  // ✅ SharedPreferences se tags load karo
  Future<void> _loadTagsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTags = prefs.getStringList('custom_reasons');
    if (savedTags != null && savedTags.isNotEmpty) {
      tags.assignAll(savedTags);
    }
  }

  // ✅ SettingsController se live update ke liye
  void updateTags(List<String> newTags) {
    tags.assignAll(newTags);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    String? savedJoinDate = prefs.getString('user_join_date');
    DateTime joinDate;
    if (savedJoinDate == null) {
      joinDate = DateTime.now();
      await prefs.setString('user_join_date', joinDate.toIso8601String());
    } else {
      joinDate = DateTime.parse(savedJoinDate);
    }

    String? daysJson = prefs.getString('saved_days');
    Map<String, List<PrayerStatus>> existingData = {};
    if (daysJson != null) {
      Map<String, dynamic> decoded = jsonDecode(daysJson);
      decoded.forEach((key, value) {
        existingData[key] = (value as List)
            .map((e) => PrayerStatus.values[e])
            .toList();
      });
    }

    String? notesJson = prefs.getString('saved_notes');
    if (notesJson != null) {
      Map<String, dynamic> decodedNotes = jsonDecode(notesJson);
      notes.value = decodedNotes.map(
        (key, value) => MapEntry(key, Map<String, String>.from(value)),
      );
    }

    hasSeenMissedHint.value = prefs.getBool('has_seen_missed_hint') ?? false;

    _generateDynamicDays(existingData, joinDate);
    await _loadFromApi();
    _calculateStreak();
    _updateMissedList();
  }

  Future<void> _loadFromApi() async {
    try {
      final records = await ApiService.getSalahaRecords();
      if (records.isEmpty) return;

      final prayerNames = ['Fajr', 'Dhuhr', 'Asar', 'Maghrib', 'Isha'];
      final prayerNameMap = {
        'Fajr': 0,
        'Dhuhr': 1,
        'Asar': 2,
        'Asr': 2,
        'Maghrib': 3,
        'Isha': 4,
        'fajr': 0,
        'dhuhr': 1,
        'asar': 2,
        'asr': 2,
        'maghrib': 3,
        'isha': 4,
      };

      for (var record in records) {
        final dateStr = record['date']?.toString() ?? '';
        DateTime parsedDate;
        try {
          parsedDate = DateTime.parse(dateStr);
        } catch (e) {
          continue;
        }

        final datePrefix =
            "${parsedDate.day.toString().padLeft(2, '0')}"
            ".${parsedDate.month.toString().padLeft(2, '0')}"
            ".${parsedDate.year.toString().substring(2)}";

        String? matchedKey = days.keys.toList().firstWhereOrNull(
          (k) => k.startsWith(datePrefix),
        );
        if (matchedKey == null) continue;

        final prayerType = record['prayer_type']?.toString() ?? '';
        int? pIdx = prayerNameMap[prayerType];
        if (pIdx == null) continue;

        final statusStr = ApiService.statusFromLaravel(
          record['status']?.toString() ?? '',
        );
        final apiStatus = PrayerStatus.values.firstWhere(
          (e) => e.name == statusStr,
          orElse: () => PrayerStatus.none,
        );

        if (days[matchedKey] != null && pIdx < days[matchedKey]!.length) {
          final localStatus = days[matchedKey]![pIdx];
          if (localStatus != PrayerStatus.late) {
            days[matchedKey]![pIdx] = apiStatus;
          }
        }

        final reason = record['reason']?.toString() ?? '';
        final noteText = record['notes']?.toString() ?? '';
        final finalNote = reason.isNotEmpty ? reason : noteText;
        if (finalNote.isNotEmpty) {
          if (notes[matchedKey] == null) notes[matchedKey] = {};
          notes[matchedKey]![prayerNames[pIdx]] = finalNote;
        }
      }

      days.refresh();
      notes.refresh();
      await saveData();
    } catch (e) {}
  }

  void _generateDynamicDays(
    Map<String, List<PrayerStatus>> existingData,
    DateTime joinDate,
  ) {
    final Map<String, List<PrayerStatus>> updatedMap = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(joinDate.year, joinDate.month, joinDate.day);

    for (
      DateTime d = today;
      d.isAfter(startDate.subtract(const Duration(days: 1)));
      d = d.subtract(const Duration(days: 1))
    ) {
      String label = _getFormattedLabel(d);
      updatedMap[label] =
          existingData[label] ?? List.generate(5, (_) => PrayerStatus.none);
    }
    days.assignAll(updatedMap);
  }

  String _getFormattedLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(d.year, d.month, d.day);
    final diff = today.difference(date).inDays;

    // ✅ Sirf yeh line badli — . ki jagah /
    String datePart =
        "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year.toString().substring(2)}";
    if (diff == 0) return '$datePart Today';
    if (diff == 1) return '$datePart Yesterday';

    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '$datePart ${weekdays[d.weekday - 1]}';
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, List<int>> saveDays = days.map(
      (k, v) => MapEntry(k, v.map((e) => e.index).toList()),
    );
    await prefs.setString('saved_days', jsonEncode(saveDays));
    await prefs.setString('saved_notes', jsonEncode(notes));
  }

  void setStatus(String dayKey, int index, PrayerStatus status) async {
    if (!days.containsKey(dayKey)) return;

    days[dayKey]![index] = status;
    final prayerNames = ['Fajr', 'Dhuhr', 'Asar', 'Maghrib', 'Isha'];

    if (notesController.text.isNotEmpty) {
      if (notes[dayKey] == null) notes[dayKey] = {};
      notes[dayKey]![prayerNames[index]] = notesController.text;
    } else if (status == PrayerStatus.prayed) {
      notes[dayKey]?.remove(prayerNames[index]);
    }

    days.refresh();
    notes.refresh();
    _calculateStreak();
    _updateMissedList();
    saveData();

    await ApiService.saveSalahaRecord(
      prayerIndex: index,
      status: status.name,
      notes: notesController.text.isNotEmpty ? notesController.text : null,
      tags: selectedTags.toList(),
    );

    selectedTags.clear();
    notesController.clear();
  }

  void _calculateStreak() {
    int streak = 0;
    var sortedKeys = days.keys.toList().reversed.toList();

    for (var key in sortedKeys) {
      final prayers = days[key]!;
      bool isAllFilled = prayers.every((s) => s != PrayerStatus.none);
      bool isAllPrayed = prayers.every(
        (s) =>
            s == PrayerStatus.prayed ||
            s == PrayerStatus.excused ||
            s == PrayerStatus.late,
      );

      if (isAllFilled && isAllPrayed) {
        streak++;
      } else if (prayers.any((s) => s == PrayerStatus.missed)) {
        streak = 0;
      }
    }
    currentStreak.value = streak;
  }

  void _updateMissedList() {
    missedSalahs.clear();
    final prayerNames = ['Fajr', 'Dhuhr', 'Asar', 'Maghrib', 'Isha'];
    days.forEach((dayKey, prayers) {
      for (int i = 0; i < prayers.length; i++) {
        if (prayers[i] == PrayerStatus.missed) {
          missedSalahs.add(
            MissedSalah(
              dayKey: dayKey,
              prayerIndex: i,
              prayerName: prayerNames[i],
            ),
          );
        }
      }
    });
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
    notesController.text = selectedTags.join(', ');
  }

  Future<void> markMissedHintSeen() async {
    hasSeenMissedHint.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_missed_hint', true);
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
