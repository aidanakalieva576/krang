import 'package:flutter/material.dart';
import '../../components/navbar.dart';
import '../../components/movies.dart';
import '../../components/categoriesComp.dart';
import '../../components/search.dart';
import '../../components/actors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

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
              padding: const EdgeInsets.all(12),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: const [
                  Search(),
                  SizedBox(height: 20),
                  CategorySection(),
                  SizedBox(height: 20),
                  MovieSection(title: 'Popular Right Now'),
                  MovieSection(title: 'Watching right now'),
                  MovieSection(title: 'New'),
                  MovieSection(title: 'Coming soon'),
                  ActorSection(),
                ],
              ),
            ),
          ),

          // ✅ Навбар наложен поверх страницы, контент под ним виден
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
