import 'package:flutter/material.dart';
import '../../components/navbar.dart';
import '../../components/movies_header.dart';
import '../../components/movie_card.dart';

class MyMoviesPage extends StatefulWidget {
  const MyMoviesPage({super.key});

  @override
  State<MyMoviesPage> createState() => _MyMoviesPageState();
}

class _MyMoviesPageState extends State<MyMoviesPage> {
  int _selectedIndex = 2;

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MoviesHeader(),

                  const SizedBox(height: 8),

                  // 🔘 Кнопка "Continue watching" — потоньше и с отступами
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/continue_watching'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2C),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Continue watching',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🎬 Список фильмов
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        MovieCard(
                          imagePath: 'assets/icons_user/brooklyn_movie.png',
                          title: 'Brooklyn Nine-Nine',
                          subtitle: 'Sitcom, 2003',
                          seasons: '8 seasons',
                        ),
                        SizedBox(height: 12),
                        MovieCard(
                          imagePath:
                          'assets/icons_user/desperate_housewives.png',
                          title: 'Desperate Housewives',
                          subtitle: 'Drama, 2004',
                          seasons: '8 seasons',
                        ),
                        SizedBox(height: 12),
                        MovieCard(
                          imagePath: 'assets/icons_user/arcane.png',
                          title: 'Arcane',
                          subtitle: 'Action, 2021',
                          seasons: '2 seasons',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ⚓ Навбар у нижнего края
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
