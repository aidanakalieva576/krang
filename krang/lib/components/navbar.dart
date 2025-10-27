import 'package:flutter/material.dart';
import '../pages/User/home.dart';
import '../pages/User/my_movies.dart';
import '../pages/User/profile_page.dart';
import '../pages/User/categories.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  final List<String> icons = const [
    'assets/icons_user/home.png',
    'assets/icons_user/nav_search.png',
    'assets/icons_user/nav_fav.png',
    'assets/icons_user/nav_user.png',
  ];

  void _navigateToPage(BuildContext context, int index) {
    Widget page;

    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const CategoriesPage();
        break;
      case 2:
        page = const MyMoviesPage();
        break;
      case 3:
        page = const ProfilePage();
        break;
      default:
        page = const HomePage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
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
            (index) => GestureDetector(
              onTap: () {
                onItemTapped(index);
                _navigateToPage(context, index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? Colors.white.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  icons[index],
                  fit: BoxFit.contain,
                  color: selectedIndex == index
                      ? Colors.white
                      : Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
