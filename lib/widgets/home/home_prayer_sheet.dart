import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shahada_app_getx/controllers/home_controller.dart';

String _formatShortDate(String dateStr) {
  try {
    final parts = dateStr.split('.');
    final day = parts[0];
    final month = int.parse(parts[1]);
    final year = '20${parts[2]}';
    const monthNames = [
      '',
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
    return '$day-${monthNames[month]}-$year';
  } catch (_) {
    return dateStr;
  }
}

void showPrayerSheet(
  BuildContext context,
  HomeController controller,
  String dayKey,
  int prayerIndex, {
  bool isEdit = false,
  bool isView = false,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final prayerNames = ['Fajr', 'Dhuhr', 'Asar', 'Maghrib', 'Isha'];
  final parts = dayKey.split(' ');
  final dateStr = parts[0];
  final dayLabel = parts[1];
  final dayDisplay = dayLabel == 'Today'
      ? 'today'
      : 'on ${_formatShortDate(dateStr)}';
  // final dayDisplay = dayLabel == 'Today' ? 'today' : 'on $dateStr';

  final existingStatus =
      controller.days[dayKey]?[prayerIndex] ?? PrayerStatus.none;

  // ✅ isView mein bhi purani value load karo
  controller.selectedStatus.value = (isEdit || isView)
      ? existingStatus
      : PrayerStatus.none;

  if (isEdit || isView) {
    // ✅ isView mein bhi purane tags load karo
    String? savedNote = controller.notes[dayKey]?[prayerNames[prayerIndex]];
    if (savedNote != null) {
      controller.notesController.text = savedNote;
      controller.selectedTags.clear();
      controller.selectedTags.addAll(
        savedNote.split(', ').map((e) => e.trim()),
      );
    }
  } else {
    controller.selectedTags.clear();
    controller.notesController.clear();
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            final selected = controller.selectedStatus.value;
            final showReasons =
                selected != PrayerStatus.prayed &&
                selected != PrayerStatus.none;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      isEdit
                          ? 'Edit ${prayerNames[prayerIndex]} $dayDisplay'
                          : 'How did you pray ${prayerNames[prayerIndex]} $dayDisplay?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _prayerOption(
                        label: 'In Jamaah',
                        status: PrayerStatus.prayed,
                        color: const Color(0xFF5FB27E),
                        icon: Icons.account_circle_outlined,
                        selected: selected,
                        onTap: isView
                            ? () {}
                            : () => setState(() {
                                // ✅ view mode mein tap band
                                controller.selectedStatus.value =
                                    PrayerStatus.prayed;
                              }),
                      ),
                      _prayerOption(
                        label: 'On Time',
                        status: PrayerStatus.excused,
                        color: const Color(0xFF6C4A8E),
                        icon: Icons.local_florist_rounded,
                        selected: selected,
                        onTap: isView
                            ? () {}
                            : () => setState(() {
                                controller.selectedStatus.value =
                                    PrayerStatus.excused;
                              }),
                      ),
                      _prayerOption(
                        label: 'Late',
                        status: PrayerStatus.late,
                        color: const Color(0xFF8B4A2F),
                        icon: Icons.access_time,
                        selected: selected,
                        onTap: isView
                            ? () {}
                            : () => setState(() {
                                controller.selectedStatus.value =
                                    PrayerStatus.late;
                              }),
                      ),
                      _prayerOption(
                        label: 'Missed',
                        status: PrayerStatus.missed,
                        color: const Color(0xFF8E2C34),
                        icon: Icons.block,
                        selected: selected,
                        onTap: isView
                            ? () {}
                            : () => setState(() {
                                controller.selectedStatus.value =
                                    PrayerStatus.missed;
                              }),
                      ),
                    ],
                  ),
                  if (showReasons) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Reasons :',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.tags.map((tag) {
                          final isSelected = controller.selectedTags.contains(
                            tag,
                          );
                          return GestureDetector(
                            onTap: isView
                                ? null
                                : () => controller.toggleTag(
                                    tag,
                                  ), // ✅ view mode mein tag tap band
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xff1E73BE)
                                    : Color(0xff1E73BE).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.notesController,
                    readOnly: isView, // ✅ view mode mein notes edit band
                    decoration: InputDecoration(
                      hintText: 'Notes',
                      filled: true,
                      fillColor: Colors.grey.shade400,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ✅ isView = true hone par button bilkul nahi dikhega
                  if (!isView)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: selected == PrayerStatus.none
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF2F80ED),
                                    Color(0xFF27AE60),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ).scale(0.4)
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF2F80ED),
                                    Color(0xFF27AE60),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: selected == PrayerStatus.none
                              ? null
                              : () {
                                  controller.setStatus(
                                    dayKey,
                                    prayerIndex,
                                    selected,
                                  );
                                  Get.back();
                                },
                          child: Text(
                            isEdit ? 'Update' : 'Save',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Widget _prayerOption({
  required String label,
  required PrayerStatus status,
  required Color color,
  required IconData icon,
  required PrayerStatus selected,
  required VoidCallback onTap,
}) {
  final isSelected = selected == status;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: isSelected ? color : color.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: Colors.white, width: 2.5) : null,
        boxShadow: isSelected
            ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              fontSize: 11,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
