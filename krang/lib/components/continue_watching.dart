import 'package:flutter/material.dart';

class ContinueWatchingItem extends StatelessWidget {
  final String title;
  final String imagePath; // URL или asset
  final double progress;

  const ContinueWatchingItem({
    super.key,
    required this.title,
    required this.imagePath,
    required this.progress,
  });

  bool get _isNetwork => imagePath.startsWith('http://') || imagePath.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 100,
        decoration: const BoxDecoration(color: Color(0xFF252525)),
        child: Stack(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 10, bottom: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 70,
                      height: 70,
                      child: _isNetwork
                          ? Image.network(imagePath, fit: BoxFit.cover)
                          : Image.asset(imagePath, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

            // ✅ Прогресс снизу
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6, // сделай толще чтобы точно было видно
                backgroundColor: Colors.white12,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
