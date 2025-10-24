import 'package:flutter/material.dart';

class MovieDescription extends StatelessWidget {
  final String description;
  const MovieDescription({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: const TextStyle(color: Colors.white70, height: 1.4),
    );
  }
}
