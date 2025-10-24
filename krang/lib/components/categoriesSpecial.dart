import 'package:flutter/material.dart';
import '../components/navbar.dart';
import '../components/movies.dart';
import '../components/categoriesComp.dart';
import '../components/search.dart';

class Category extends StatefulWidget {
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
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
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView(
            children: const [
              Search(),
              SizedBox(height: 20),
              CategorySection(),
              SizedBox(height: 20),
              MovieSection(title: "Horror"),
              MovieSection(title: "Scifi"),
              MovieSection(title: "Action"),
              MovieSection(title: "Comedy"),
              MovieSection(title: "Drama"),
            ],
          ),
        ),
      ),
    );
  }
}
