import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String seasons;
  final VoidCallback? onTap;

  const MovieCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.seasons,
    this.onTap,
  });

  bool get _isNetworkImage =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _isNetworkImage
                  ? Image.network(
                      imagePath,
                      height: 100,
                      width: 75,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 100,
                        width: 75,
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                        ),
                      ),
                    )
                  : Image.asset(
                      imagePath,
                      height: 100,
                      width: 75,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  if (seasons.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      seasons,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
