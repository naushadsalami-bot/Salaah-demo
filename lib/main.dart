import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shahada_app_getx/Services/notification_service.dart';
import 'package:shahada_app_getx/auth/create_account_screen.dart';
import 'package:shahada_app_getx/auth/login_screen.dart';
import 'package:shahada_app_getx/auth/welcome_screen.dart';
import 'package:shahada_app_getx/Services/api_service.dart';
import 'controllers/theme_controller.dart';
import 'gender_selection_screen.dart';
import 'home_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'notification_permission_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.init(); // ✅ Fix: init zaroor karo
  await NotificationService.showNow(); // ✅ Fix: notification show karo
  print("Background message: ${message.messageId}");
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ✅ Fix: Sabse pehle background handler register karo
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  Get.put(ThemeController(), permanent: true);
  await NotificationService.init();

  final token = await ApiService.getToken();
  final initialRoute = token != null ? '/home' : '/welcome';

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shahada',

        themeMode: themeController.themeMode,

        // ☀️ LIGHT THEME
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          cardColor: Colors.grey.shade200,
          dividerColor: Colors.grey.shade300,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.black),
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),

        // 🌙 DARK THEME
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F1412),
          cardColor: const Color(0xFF1C1F1E),
          dividerColor: Colors.white24,
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
          ),
          colorScheme: const ColorScheme.dark(primary: Colors.teal),
        ),

        initialRoute: initialRoute,

        getPages: [
          GetPage(name: '/welcome', page: () => const WelcomeScreen()),
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(
            name: '/create-account',
            page: () => const CreateAccountScreen(),
          ),
          GetPage(name: '/gender', page: () => const GenderSelectionScreen()),
          GetPage(
            name: '/notification',
            page: () => const NotificationPermissionScreen(),
          ),
          GetPage(name: '/home', page: () => const HomeScreen()),
          GetPage(name: '/stats', page: () => StatsScreen()),
          GetPage(name: '/settings', page: () => const SettingsScreen()),
        ],
      ),
    );
  }
}
