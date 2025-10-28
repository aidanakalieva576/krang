import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategory('All', true),
          _buildCategory('Movies', false),
          _buildCategory('Series', false),
          _buildCategory('Cartoons', false),
          _buildCategory('Documentaries', false),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildCategory(String text, bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: active ? Colors.blue : Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
