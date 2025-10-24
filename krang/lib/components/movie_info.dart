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
            Text(
              duration, // например "2h"
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              age,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Звёздный рейтинг
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Image.asset(
                index < rating
                    ? 'assets/icons_user/star.png'
                    : 'assets/icons_user/empty_star.png',
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
