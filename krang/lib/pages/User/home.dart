import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String _searchQuery = "";      // ← ключевая переменная поиска
  int _selectedIndex = 0;
  String _selectedType = 'All';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double sectionGap = 40;

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
                  // 🔍 ПОИСК — теперь реально работает
                  Search(
                    onChanged: (text) {
                      setState(() => _searchQuery = text);
                    },
                  ),


                  const SizedBox(height: 20),

                  _buildSectionTitle("For you"),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      itemCount: carouselImages.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 16),
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

                  // Категории
                  CategorySection(
                    selected: _selectedType,
                    onSelected: (v) =>
                        setState(() => _selectedType = v),
                  ),

                  const SizedBox(height: 32),

                  // 🔹 ВСЕМ секциям передаём searchQuery
                  MovieSection(
                    title: 'Popular Right Now',
                    typeFilter: _selectedType,
                    searchQuery: _searchQuery,
                  ),
                  const SizedBox(height: sectionGap),

                  MovieSection(
                    title: 'Watching right now',
                    typeFilter: _selectedType,
                    searchQuery: _searchQuery,
                  ),
                  const SizedBox(height: sectionGap),

                  MovieSection(
                    title: 'New',
                    typeFilter: _selectedType,
                    searchQuery: _searchQuery,
                  ),
                  const SizedBox(height: sectionGap),

                  MovieSection(
                    title: 'Coming soon',
                    typeFilter: _selectedType,
                    searchQuery: _searchQuery,
                  ),

                  const SizedBox(height: 32),

                  const ActorSection(),
                ],
              ),
            ),
          ),

          // Навбар снизу
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w200,
        ),
      ),
    );
  }
}
