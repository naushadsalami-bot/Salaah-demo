import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shahada_app_getx/Services/api_service.dart';
import 'package:shahada_app_getx/widgets/app_bottom_navigation.dart';
import '../controllers/settings_controller.dart';
import 'controllers/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ✅ Error Fix: Yeh helper function null handle karega
  String _safeFormatDate(DateTime? date) {
    if (date == null) return _safeFormatDate(DateTime.now());
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : Colors.white,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          kBottomNavigationBarHeight + 40,
        ),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          _sectionTile(
            'Notifications',
            'Toggle Notifications',
            isDark: isDark,
            onTap: () => _openNotificationSheet(context, controller),
          ),
          _sectionTile(
            'Theme',
            'Change theme',
            isDark: isDark,
            onTap: () => _openThemeBottomSheet(),
          ),
          Obx(
            () => _switchTile(
              context: context,
              title: 'Missed Salah Counter',
              subtitle:
                  'Display missed salah counter (when applicable) on homepage',
              value: controller.showMissedSalahCounter.value,
              onChanged: controller.toggleMissedSalah,
            ),
          ),
          _sectionTile(
            'Change Start Date',
            'Change app start date',
            isDark: isDark,
            onTap: () => _openStartDateBottomSheet(),
          ),
          _sectionTile(
            'Edit Reasons',
            'Add or remove reasons',
            isDark: isDark,
            onTap: () => _openEditReasonsSheet(),
          ),
          _sectionTile(
            'Import Data',
            'Supports backups exported this app',
            isDark: isDark,
          ),
          _sectionTile(
            'Export Data',
            'Generates a backup file',
            isDark: isDark,
          ),
          _sectionTile('Review', 'Rate us on the Play Store', isDark: isDark),
          _sectionTile('Share', 'Share application', isDark: isDark),
          _sectionTile('Changelog', 'View changelog', isDark: isDark),
          _sectionTile(
            'Feedback',
            'Report bugs or request features',
            isDark: isDark,
          ),
          _sectionTile('Website', 'Visit our website', isDark: isDark),
          _sectionTile('Privacy Policy', 'View privacy policy', isDark: isDark),
          _sectionTile('Source Code', 'View source code', isDark: isDark),
          _sectionTile(
            'About',
            'About Shahada',
            isDark: isDark,
            onTap: _openAboutBottomSheet,
          ),
          _logoutTile(isDark: isDark),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  // --- SARE WIDGETS AUR FUNCTIONS ---

  Widget _logoutTile({required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _confirmLogout(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 14),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF2A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign out of your account',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await ApiService.logout();
              Get.offAllNamed('/login');
            },
            child: Text('Logout', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }

  Widget _sectionTile(
    String title,
    String subtitle, {
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xff3183FF),
          ),
        ],
      ),
    );
  }

  Widget _themeOption(
    String title,
    AppTheme theme,
    ThemeController controller,
    bool isDark,
  ) {
    final selected = controller.selectedTheme.value == theme;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () => controller.changeTheme(theme),
    );
  }

  void _openNotificationSheet(
    BuildContext context,
    SettingsController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.bottomSheet(
      Builder(
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white38 : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Turn on Daily Notification',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: controller.dailyNotification.value,
                        onChanged: controller.toggleDailyNotification,
                        activeColor: const Color(0xff3183FF),
                      ),
                    ],
                  ),
                  if (controller.dailyNotification.value) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: Get.context!,
                          initialTime: controller.fixedTime.value,
                        );
                        if (picked != null) controller.setFixedTime(picked);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            if (controller.notificationTimeType.value ==
                                'fixed')
                              const Icon(
                                Icons.check,
                                color: Colors.teal,
                                size: 18,
                              )
                            else
                              const SizedBox(width: 18),
                            const SizedBox(width: 8),
                            Text(
                              'At fixed time',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              controller.fixedTime.value.format(Get.context!),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          controller.setNotificationTimeType('afterIsha'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            if (controller.notificationTimeType.value ==
                                'afterIsha')
                              const Icon(
                                Icons.check,
                                color: Colors.teal,
                                size: 18,
                              )
                            else
                              const SizedBox(width: 18),
                            const SizedBox(width: 8),
                            Text(
                              'After Isha',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${controller.afterIshaMinutes.value} minutes',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.unfold_more,
                              size: 18,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Turn on Salah Notifications',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Turn this on to receive all Salah reminders.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Switch(
                          value: controller.salahNotification.value,
                          onChanged: controller.toggleSalahNotification,
                          activeColor: const Color(0xff3183FF),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _openThemeBottomSheet() {
    final themeController = Get.find<ThemeController>();
    final isDark = Get.isDarkMode;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _themeOption('Light', AppTheme.light, themeController, isDark),
              _themeOption('Dark', AppTheme.dark, themeController, isDark),
              _themeOption('System', AppTheme.system, themeController, isDark),
            ],
          ),
        ),
      ),
    );
  }

  void _openStartDateBottomSheet() {
    final controller = Get.find<SettingsController>();
    Get.bottomSheet(
      Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Obx(() {
              final dateSelected = controller.startDate.value != null;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Current Start Date',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _safeFormatDate(
                      controller.startDate.value,
                    ), // ✅ Fixed Error
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Select New Start Date',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ✅ Sirf yeh date picker button wala part replace karo
                  GestureDetector(
                    onTap: () => _pickDate(controller),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        // ✅ Fix 2 — solid teal, no gradient
                        color: const Color(0xFF1AA6A6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // ✅ Fix 1 — date set nahi toh sirf empty, set hai toh date dikhao
                          Text(
                            dateSelected
                                ? _safeFormatDate(controller.startDate.value)
                                : '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.changeStartDate(controller.startDate.value);
                        Get.back();
                      },
                      // onPressed: () => controller.changeStartDate(
                      //   controller.startDate.value,
                      // ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: dateSelected
                                ? [
                                    const Color(0xFF1E73BE),
                                    const Color(0xFF2FA4A9),
                                    const Color(0xFF2EB872),
                                  ]
                                : [
                                    const Color(0xFF1E73BE).withOpacity(0.4),
                                    const Color(0xFF2FA4A9).withOpacity(0.4),
                                    const Color(0xFF2EB872).withOpacity(0.4),
                                  ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _pickDate(SettingsController controller) async {
    DateTime selectedDate = controller.startDate.value ?? DateTime.now();
    DateTime displayedMonth = DateTime(selectedDate.year, selectedDate.month);

    await showDialog(
      context: Get.context!,
      builder: (context) {
        // ✅ Dark/Light theme detect
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black87;
        final subTextColor = isDark ? Colors.white60 : Colors.black54;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Teal Header
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF2FA4A9),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selectedDate.year}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatHeaderDate(selectedDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ Custom Month Row
                  Container(
                    color: bgColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: subTextColor),
                          onPressed: () {
                            setState(() {
                              displayedMonth = DateTime(
                                displayedMonth.year,
                                displayedMonth.month - 1,
                              );
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            _formatMonthYear(displayedMonth),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right, color: subTextColor),
                          onPressed: () {
                            setState(() {
                              displayedMonth = DateTime(
                                displayedMonth.year,
                                displayedMonth.month + 1,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  //  Calendar — gap bilkul nahi, built-in header clip se cut
                  Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: const Color(0xFF2FA4A9),
                        onPrimary: Colors.white,
                        onSurface: textColor,
                        surface: bgColor,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                          overlayColor: WidgetStateProperty.all(
                            Colors.transparent,
                          ),
                          textStyle: WidgetStateProperty.all(
                            const TextStyle(fontSize: 0),
                          ),
                          minimumSize: WidgetStateProperty.all(Size.zero),
                          maximumSize: WidgetStateProperty.all(Size.zero),
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                          fixedSize: WidgetStateProperty.all(Size.zero),
                        ),
                      ),
                      iconTheme: const IconThemeData(
                        color: Colors.transparent,
                        size: 0,
                      ),
                    ),
                    child: SizedBox(
                      width: double.maxFinite,
                      child: ClipRect(
                        child: Transform.translate(
                          offset: const Offset(0, -52), // header upar shift
                          child: SizedBox(
                            height:
                                300, // ✅ Fixed height do — overflow nahi hoga
                            child: CalendarDatePicker(
                              key: ValueKey(displayedMonth),
                              initialDate:
                                  selectedDate.month == displayedMonth.month &&
                                      selectedDate.year == displayedMonth.year
                                  ? selectedDate
                                  : DateTime(
                                      displayedMonth.year,
                                      displayedMonth.month,
                                      1,
                                    ),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                              onDateChanged: (date) {
                                setState(() {
                                  selectedDate = date;
                                  displayedMonth = DateTime(
                                    date.year,
                                    date.month,
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ✅ CLEAR + CANCEL + SET
                  Container(
                    color: bgColor,
                    padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.changeStartDate(null);
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF2FA4A9),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          child: const Text('CLEAR'),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF2FA4A9),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.changeStartDate(selectedDate);
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF1AA6A6),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          child: const Text('SET'),
                        ),
                      ],
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

  String _formatHeaderDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _formatMonthYear(DateTime date) {
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
    return '${months[date.month - 1]} ${date.year}';
  }

  void _openEditReasonsSheet() {
    final controller = Get.find<SettingsController>();
    Get.bottomSheet(
      Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          return Container(
            height: Get.height * 0.85,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.reasonTextController,
                        onChanged: (v) => controller.newReason.value = v,
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge!.color,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ✅ Add button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: controller.addReason,
                      child: Text('Add', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 4),
                    // ✅ Reset icon — Add ke side mein
                    IconButton(
                      onPressed: () => _confirmResetOrDelete(null),
                      icon: Icon(
                        Icons.refresh,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      tooltip: 'Reset to Default',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(
                    () => ListView.builder(
                      itemCount: controller.reasons.length,
                      itemBuilder: (_, index) {
                        final reason = controller.reasons[index];
                        return ListTile(
                          title: Text(
                            reason,
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge!.color,
                            ),
                          ),
                          // ✅ Close icon — black/white theme ke hisaab se
                          trailing: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: isDark ? Colors.black : Colors.white,
                              size: 12,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.white
                                  : Colors.black,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(4),
                              minimumSize: const Size(24, 24),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            constraints: const BoxConstraints(),
                            onPressed: () => _confirmResetOrDelete(reason),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _confirmResetOrDelete(String? reason) {
    final controller = Get.find<SettingsController>();
    final isDark = Get.isDarkMode;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          reason == null ? 'Reset to Default?' : 'Delete Reason?',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          reason == null
              ? 'All reasons will be reset to default.'
              : '"$reason" will be deleted.',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (reason == null) {
                controller.resetReasons(); // ✅ Reset
              } else {
                controller.removeReason(reason); // ✅ Delete
              }
              Get.back();
            },
            child: const Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openAboutBottomSheet() {
    final isDark = Get.isDarkMode;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'MyUmmahApps Ltd',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Empowering the Muslim community.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
