import 'package:flutter/material.dart';

class NavbarAdmin extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const NavbarAdmin({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  State<NavbarAdmin> createState() => _NavbarAdminState();
}

class _NavbarAdminState extends State<NavbarAdmin> {
  final List<String> icons = [
    'assets/icons_admin/icon_movies.png',
    'assets/icons_admin/icon_users.png',
    'assets/icons_admin/icon_stats.png',
    'assets/icons_admin/icon_support.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0x80414553), // фон, как на макете
        borderRadius: BorderRadius.circular(40), // скругление как на Figma
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          icons.length,
          (index) => _buildNavItem(icons[index], index),
        ),
      ),
    );
  }

  Widget _buildNavItem(String assetPath, int index) {
    final bool isSelected = widget.selectedIndex == index;

    return GestureDetector(
      onTap: () => widget.onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(6),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          color: isSelected ? Colors.white : Colors.grey.shade400,
        ),
      ),
    );
  }
}
