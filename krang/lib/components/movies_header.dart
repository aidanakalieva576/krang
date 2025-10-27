import 'package:flutter/material.dart';

class MoviesHeader extends StatelessWidget {
  const MoviesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 24, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // заголовок остаётся слева
        children: [
          Text(
            'My movies',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16), // немного больше расстояние
          Center( // центрируем только описание
            child: Text(
              "This is a personalized section where\nyou can find the movies you’ve watched",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
