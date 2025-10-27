import 'package:flutter/material.dart';
import '../../components/navbar.dart';
import '../../components/movies.dart';
import '../../components/categoriesComp.dart';
import '../../components/search.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: const [
                  // 🔍 Поиск
                  Search(),
                  SizedBox(height: 28),

                  // 🧩 Категории
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Categories",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  CategorySection(),

                  // 🎬 Фильмы
                  SizedBox(height: 32),
                  MovieSection(title: 'Popular Right Now'),
                  SizedBox(height: 32),
                  MovieSection(title: 'Watching right now'),
                  SizedBox(height: 32),
                  MovieSection(title: 'New'),
                  SizedBox(height: 32),
                  MovieSection(title: 'Coming soon'),
                ],
              ),
            ),
          ),

          // ✅ Нижняя панель навигации
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}
