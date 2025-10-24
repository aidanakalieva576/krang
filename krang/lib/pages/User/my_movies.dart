import 'package:flutter/material.dart';
import 'package:krang/components/navbar.dart';
import '../../components/movies_header.dart';
import '../../components/movie_card.dart';

class MyMoviesPage extends StatefulWidget {
  const MyMoviesPage({super.key});

  @override
  State<MyMoviesPage> createState() => _MyMoviesPageState();
}

class _MyMoviesPageState extends State<MyMoviesPage> {
  int _selectedIndex = 2; // вкладка "My Movies"

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // можно добавить навигацию
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Основной контент
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MoviesHeader(),

                  // ✅ Красивая серая кнопка "Continue watching"
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/continue_watching'),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Continue watching',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const MovieCard(
                    imagePath: 'assets/icons_user/brooklyn_movie.png',
                    title: 'Brooklyn Nine-Nine',
                    subtitle: 'Sitcom, 2003',
                    seasons: '8 seasons',
                  ),
                  const MovieCard(
                    imagePath: 'assets/icons_user/desperate_housewives.png',
                    title: 'Desperate Housewives',
                    subtitle: 'Drama, 2004',
                    seasons: '8 seasons',
                  ),
                  const MovieCard(
                    imagePath: 'assets/icons_user/arcane.png',
                    title: 'Arcane',
                    subtitle: 'Action, 2021',
                    seasons: '2 seasons',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ✅ Навбар строго прижат к низу
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
