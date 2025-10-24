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
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),

        // Время и возраст
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
<<<<<<< HEAD
            Image.asset(
              'assets/icons/time.png',
              width: 16,
              height: 16,
              color: Colors.white70,
=======
            Text(
              duration, // например "2h"
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
>>>>>>> d7edde5cc50e90f2fe95a2513c9fecbbaa1d363f
            ),
            const SizedBox(width: 16),
            Text(
              age,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
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
<<<<<<< HEAD
                    ? 'assets/icons_admin/full_star.png'
                    : 'assets/icons_admin/star.png',
=======
                    ? 'assets/icons_user/star.png'
                    : 'assets/icons_user/empty_star.png',
>>>>>>> d7edde5cc50e90f2fe95a2513c9fecbbaa1d363f
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
