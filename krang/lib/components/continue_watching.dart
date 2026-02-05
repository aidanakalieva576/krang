import 'package:flutter/material.dart';

class ContinueWatchingItem extends StatelessWidget {
  final String title;
  final String imagePath;
  final double progress;

  const ContinueWatchingItem({
    super.key,
    required this.title,
    required this.imagePath,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12), // ✅ обрезаем всё, включая прогресс-бар
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF252525), // светлее фона
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Основной контент
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 📸 Картинка
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 10, bottom: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      imagePath,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 🔵 Прогресс-бар внизу контейнера
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LinearProgressIndicator(
                value: progress,
                color: Colors.blueAccent,
                backgroundColor: Colors.grey[800],
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
