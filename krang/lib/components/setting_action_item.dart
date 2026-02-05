import 'package:flutter/material.dart';

class SettingsActionItem extends StatelessWidget {
  final String title;
  final IconData? icon; // ✅ иконка теперь необязательная
  final Color color;
  final VoidCallback onTap;

  const SettingsActionItem({
    super.key,
    required this.title,
    this.icon, // ✅ можно не передавать
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // ✅ Показываем иконку только если она передана
            if (icon != null) ...[
              Icon(icon, color: color),
              const SizedBox(width: 10),
            ],
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );

  }
}
