import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        print("Notification Clicked!");
      },
    );

    await FirebaseMessaging.instance.requestPermission();

    String? token = await FirebaseMessaging.instance.getToken();
    print("🚀 FCM TOKEN: $token");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNow();
    });

    // ✅ App restart hone par saved time se reschedule karo
    await rescheduleFromPrefs();
  }

  // ✅ SharedPreferences se time padh ke reschedule karo
  static Future<void> rescheduleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isOn = prefs.getBool('daily_notification_on') ?? false;
    if (!isOn) return;

    final hour = prefs.getInt('notification_hour') ?? 21;
    final minute = prefs.getInt('notification_minute') ?? 0;
    await scheduleDaily(TimeOfDay(hour: hour, minute: minute));
    print("🔁 Rescheduled from prefs: $hour:$minute");
  }

  //
  static Future<void> scheduleDailyAndSave(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_notification_on', true);
    await prefs.setInt('notification_hour', time.hour);
    await prefs.setInt('notification_minute', time.minute);
    await scheduleDaily(time);
  }

  //
  static Future<void> cancelAllAndSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_notification_on', false);
    await cancelAll();
  }

  static Future<void> showNow() async {
    await _notifications.show(
      101,
      'Daily Reminder',
      'Did you log your prayers today? ',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel_new_v10',
          'Daily Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> scheduleDaily(TimeOfDay time) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      100,
      'Daily Reminder',
      'Did you log your prayers today?',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel_new_v10',
          'Daily Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print("✅ Scheduled for: $scheduledDate");
  }

  static Future<void> cancelAll() async => await _notifications.cancelAll();
}
