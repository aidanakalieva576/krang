import 'package:flutter/material.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Верхняя панель
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ✅ Только фото (ровное, без круга)
        ClipRRect(
          borderRadius: BorderRadius.circular(16), // чуть скруглённые края
          child: Image.asset(
            'assets/icons_user/avatar.png',
            width: 120,
            height: 120,
            fit: BoxFit.cover, // полностью заполняет без искажений
          ),
        ),

        const SizedBox(height: 12),
        const Text(
          'Alexis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Change profile nickname',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
