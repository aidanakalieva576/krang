import 'dart:ui';
import 'package:flutter/material.dart';

class MovieDetailPage extends StatelessWidget {
  const MovieDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // 🔹 Фон-постер (меньше и верх виден)
          Positioned.fill(
            child: Image.asset(
              'assets/icons_user/ITonya.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          // 🔹 Более глубокий черный градиент
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xE6000000),
                    Color(0xFF000000),
                  ],
                  stops: [0.2, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // 🔹 Контент
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Назад и избранное
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset(
                          'assets/icons_admin/line_to_back.png',
                          width: 36,
                          height: 36,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: добавить функционал избранного
                        },
                        child: Image.asset(
                          'assets/icons_user/heart.png',
                          width: 42,
                          height: 42,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 140), // меньшее пространство для постера

                  // 🔹 Название фильма (по центру)
                  const Center(
                    child: Text(
                      'I, Tonya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔹 Центрированный блок с рейтингом, жанром, временем и возрастом
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          '8.5 · Tragicomedy, LuckyChap',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '2 h | 18+',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // ⭐️ Рейтинг звёздами
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final filled = index < 4;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Image.asset(
                                filled
                                    ? 'assets/icons_admin/full_star.png'
                                    : 'assets/icons_admin/star.png',
                                width: 24,
                                height: 24,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 📝 Описание
                  const Text(
                    'I, Tonya is a 2017 American biographical sports film chronicling the tumultuous life of American figure skater Tonya Harding, focusing on her rise, her abusive upbringing, dysfunctional relationships, and her involvement in the infamous 1994 attack on rival Nancy Kerrigan.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),

                  const SizedBox(height: 25),

                  // 📋 Информация
                  buildInfoRow('Year', '2023'),
                  const SizedBox(height: 10),
                  buildInfoRow('Platform', 'LuckyChap'),
                  const SizedBox(height: 10),
                  buildInfoRow('Director', 'Craig Gillespie'),

                  const SizedBox(height: 40),

                  // 🔘 Кнопка "Watch"
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 72, 98, 128),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/watch');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Watch',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
