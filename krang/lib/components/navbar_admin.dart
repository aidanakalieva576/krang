import 'package:flutter/material.dart';
import '../pages/admin/home_page_admin.dart';
import '../pages/admin/users_page_admin.dart';
import '../pages/admin/stats_page_admin.dart';
import '../pages/admin/admin_settings_page.dart';

class NavbarAdmin extends StatefulWidget {
  final int selectedIndex;
  final Function(int)? onItemTapped;

  const NavbarAdmin({Key? key, required this.selectedIndex, this.onItemTapped})
    : super(key: key);

  @override
  State<NavbarAdmin> createState() => _NavbarAdminState();
}

class _NavbarAdminState extends State<NavbarAdmin> {
  final List<String> icons = [
    'assets/icons_admin/icon_movies.png',
    'assets/icons_admin/icon_users.png',
    'assets/icons_admin/icon_stats.png',
    'assets/icons_user/nav_user.png',
  ];

  void _handleNavigation(BuildContext context, int index) {
    // Вызываем колбэк (если нужно обновить selectedIndex снаружи)
    if (widget.onItemTapped != null) widget.onItemTapped!(index);

    // Локальная навигация
    Widget? targetPage;

    switch (index) {
      case 0:
        targetPage = HomePageAdmin();
        break;
      case 1:
        targetPage = UsersPageAdmin();
        break;
      case 2:
        targetPage = StatsPageAdmin();
        break;
      case 3:
        targetPage = AdminSettingsPage();
        break;
    }

    if (targetPage != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => targetPage!,
          transitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 65, 69, 83),
        borderRadius: BorderRadius.circular(40),
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
          (index) => _buildNavItem(context, icons[index], index),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String assetPath, int index) {
    final bool isSelected = widget.selectedIndex == index;

    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
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
