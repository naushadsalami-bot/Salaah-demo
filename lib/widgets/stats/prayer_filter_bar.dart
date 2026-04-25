import 'package:flutter/material.dart';

class PrayerFilterBar extends StatelessWidget {
  final List<String> prayers;
  final String selected;
  final Color darkGreenBg;
  final Color accentGold;
  final ValueChanged<String> onSelected;

  const PrayerFilterBar({
    super.key,
    required this.prayers,
    required this.selected,
    required this.darkGreenBg,
    required this.accentGold,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: darkGreenBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: prayers
            .map(
              (p) => Expanded(
                child: GestureDetector(
                  onTap: () => onSelected(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected == p ? accentGold : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      p,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected == p ? Colors.black : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
