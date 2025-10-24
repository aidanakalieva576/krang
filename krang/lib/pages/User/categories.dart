import 'package:flutter/material.dart';
import '../../components/navbar.dart';
import '../../components/movies.dart';
import '../../components/categoriesSpecial.dart';
import '../../components/search.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  int _selectedIndex = 1; // например, страница "категории" — вторая вкладка

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // здесь можно добавить переходы, если нужно
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: const [
                  Search(),
                  SizedBox(height: 20),
                  Category(),
                  SizedBox(height: 20),
                  MovieSection(title: "You may like"),
                  MovieSection(title: "Now watching"),
                  MovieSection(title: "Coming soon"),
                ],
              ),
            ),
          ),

          // ✅ Навбар поверх контента
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
