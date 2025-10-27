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
    final List<String> carouselImages = [
      'assets/icons_user/the_woman_in_cabin_10.png',
      'assets/icons_user/pickup.png',
      'assets/icons_user/play_dirty.png',
    ];

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
                  const Search(),
                  const SizedBox(height: 28),

                  // 🔥 Каруселька "Popular Right Now"
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "New Realeses",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120, // чуть выше для лучшего баланса
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: carouselImages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            carouselImages[index],
                            width: 196,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                  const CategorySection(),
                  const SizedBox(height: 32),
                  const MovieSection(title: 'Popular Right Now'),
                  const SizedBox(height: 32),
                  const MovieSection(title: 'Watching right now'),
                  const SizedBox(height: 32),
                  const MovieSection(title: 'New'),
                  const SizedBox(height: 32),
                  const MovieSection(title: 'Coming soon'),
                  const SizedBox(height: 32),
                  const ActorSection(),
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
