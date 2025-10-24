import 'package:flutter/material.dart';

class MovieInfo extends StatelessWidget {
  final String title;
  final String subtitle;
  final String duration;
  final String age;
  final double rating;

  const MovieInfo({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.age,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 300),

        // Название
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),

        // Время и возраст
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/time.png',
              width: 16,
              height: 16,
              color: Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(duration, style: const TextStyle(color: Colors.white70)),
            const SizedBox(width: 16),
            Text(age, style: const TextStyle(color: Colors.white70)),
          ],
        ),

        const SizedBox(height: 12),

        // Звёздный рейтинг из ассетов
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Image.asset(
                index < rating
                    ? 'assets/icons_admin/full_star.png'
                    : 'assets/icons_admin/star.png',
                width: 20,
                height: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
