import 'dart:ui';
import 'package:flutter/material.dart';

class EditMoviePage extends StatelessWidget {
  final String movieId;
  final String title;
  final String category;
  final String thumbnailUrl;

  const EditMoviePage({
    super.key,
    required this.movieId,
    required this.title,
    required this.category,
    required this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    print('📄 Открыта страница редактирования: $title');

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // 🔹 Размытый фон постера
          SizedBox.expand(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/icons_user/lego_movie.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // 🔹 Тёмный градиент
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black87,
                  Colors.black,
                ],
              ),
            ),
          ),

          // 🔹 Основное содержимое
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Кнопка "Назад"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset(
                          'assets/icons_admin/line_to_back.png',
                          width: 36,
                          height: 36,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 📸 Постер
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        thumbnailUrl,
                        width: 250,
                        height: 380,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              'assets/icons_user/lego_movie.jpeg',
                              width: 250,
                              height: 380,
                              fit: BoxFit.cover,
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Название фильма
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Подзаголовок
                  Text(
                    '7.7 · $category',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  // ⭐️ Рейтинг
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
                          width: 28,
                          height: 28,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 25),

                  // 📝 Описание
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Description',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'An ordinary LEGO construction worker, thought to be the prophesied as "special", is recruited to join a quest to stop an evil tyrant from gluing the LEGO universe into eternal stasis.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 25),
                      ],
                    ),
                  ),

                  // ℹ️ Информация
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        buildInfoRow('Year of production', '2014'),
                        const SizedBox(height: 10),
                        buildInfoRow('Platform', 'The Warner Animation Group'),
                        const SizedBox(height: 10),
                        buildInfoRow('Director', 'Phil Lord, Christopher Miller'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🎬 Кнопка Watch
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/watch');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color.fromARGB(255, 72, 98, 128),
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
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 150,
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
