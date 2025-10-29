import 'package:flutter/material.dart';

class CategorySection extends StatefulWidget {
  const CategorySection({super.key});

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  int _selectedIndex = 0;

  final List<String> categories = [
    'All',
    'Movies',
    'Series',
    'Cartoons',
    'Documentaries',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(
            categories.length,
                (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
              child: _buildCategory(
                categories[index],
                _selectedIndex == index,
              ),
            ),
          ),
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
        color: active
            ? const Color(0xFF5D648B)
            : const Color(0xFF343641),
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
