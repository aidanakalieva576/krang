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
          // 🔹 Размытый фон с постером
          SizedBox.expand(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Image.asset(
                'assets/icons_user/ITonya.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔹 Затемнение для контраста
          Container(color: Colors.black.withOpacity(0.6)),

          // 🔹 Основной контент
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Назад
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/icons_admin/line_to_back.png',
                      width: 36,
                      height: 36,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 📸 Постер
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/icons_user/ITonya.png',
                        width: 200,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Название
                  const Text(
                    'I, Tonya',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Подзаголовок
                  const Text(
                    '8.5 · Tragicomedy, LuckyChap',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const SizedBox(height: 12),

                  // ⭐️ Рейтинг (фиксированный)
                  Row(
                    children: List.generate(5, (index) {
                      final filled = index < 4; // 4 из 5 звёзд
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Image.asset(
                          filled
                              ? 'assets/icons_admin/full_star.png'
                              : 'assets/icons_admin/star.png',
                          width: 26,
                          height: 26,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 25),

                  // 📝 Описание
                  const Text(
                    'I, Tonya is a 2017 American biographical sports film chronicling the tumultuous life of American figure skater Tonya Harding, focusing on her rise, her abusive upbringing, dysfunctional relationships, and her involvement in the infamous 1994 attack on rival Nancy Kerrigan.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 📋 Дополнительная информация
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
                      color: Color.fromARGB(255, 72, 98, 128),
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

  // 🔹 Функция для вывода инфо-блоков (Year / Platform / Director)
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
