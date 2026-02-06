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
  String _searchQuery = "";
  int _selectedIndex = 1;
  String _selectedType = 'All';

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
                children: [
                  // 🔍 Поиск
                  Search(
                    onChanged: (text) {
                      debugPrint("🔍 SEARCH: $text");
                    },
                  ),
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
                  CategorySection(
                    selected: _selectedType,
                    onSelected: (v) => setState(() => _selectedType = v),
                  ),

                  // 🎬 Фильмы
                  SizedBox(height: 32),
                  MovieSection(
                    title: 'Popular Right Now',
                    typeFilter: _selectedType,
                    searchQuery: _searchQuery,
                  ),
                  SizedBox(height: 32),
                  MovieSection(
                    title: 'Watching right now',
                    typeFilter: _selectedType,
                    searchQuery: _searchQuery,
                  ),
                  SizedBox(height: 32),
                  MovieSection(title: 'New', typeFilter: _selectedType, searchQuery: _searchQuery,),
                  SizedBox(height: 32),
                  MovieSection(title: 'Coming soon', typeFilter: _selectedType, searchQuery: _searchQuery,),
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
