import 'package:flutter/material.dart';
import '../../components/navbar.dart';
import '../../components/movies.dart';
import '../../components/categoriesComp.dart';
import '../../components/search.dart';
import '../../components/actors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
    );
  }
}
