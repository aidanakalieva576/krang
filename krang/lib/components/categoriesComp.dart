import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  final String selected; // 'All' | 'MOVIE' | 'SERIES'
  final ValueChanged<String> onSelected;

  const CategorySection({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  List<Map<String, String>> get categories => const [
    {'label': 'All', 'value': 'All'},
    {'label': 'Movies', 'value': 'MOVIE'},
    {'label': 'Series', 'value': 'SERIES'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...categories.map((c) {
            final isActive = selected == c['value'];
            return GestureDetector(
              onTap: () => onSelected(c['value']!),
              child: _buildCategory(c['label']!, isActive),
            );
          }).toList(),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildCategory(String text, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 125,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF5D648B) : const Color(0xFF343641),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
