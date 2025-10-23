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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      bottomNavigationBar: const CustomBottomNavBar(),
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ListView(
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
          )
      ),
    );
  }
}
