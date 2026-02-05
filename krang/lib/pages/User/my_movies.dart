import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  static const String _baseUrl = 'http://172.20.10.4:8080';

  // если у твоего navbar высота другая — поменяй
  static const double _navBarHeight = 92;

  bool get _fewMovies => _favorites.length <= 2;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _fetchFavorites() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        if (!mounted) return;
        setState(() {
          _favorites = [];
          _isLoading = false;
        });
        return;
      }

      final res = await http.get(
        Uri.parse('$_baseUrl/api/user/favorites'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _favorites = data.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Favorites load error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MoviesHeader(),
        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/continue_watching'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
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
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),

          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            )
          else if (_favorites.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: Text(
                    'No favorite movies yet',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final movie = _favorites[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MovieCard(
                      imagePath: movie['thumbnail_url'] ?? '',
                      title: movie['title'] ?? '',
                      subtitle: movie['category'] ?? '',
                      seasons: '',
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          '/movie_details',
                          arguments: {'movieId': movie['id']},
                        );

                        if (result == true) {
                          await _fetchFavorites();
                        }
                      },
                    ),
                  );
                }, childCount: _favorites.length),
              ),
            ),

          // ✅ ВСЕГДА добавляем отступ под навбар
          SliverToBoxAdapter(
            child: SizedBox(height: _navBarHeight + bottomSafe + 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildBody(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      extendBody: !_fewMovies,

      // 🟢 МАЛО ФИЛЬМОВ — обычный navbar
      bottomNavigationBar: _fewMovies
          ? CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            )
          : null,

      // 🔵 МНОГО ФИЛЬМОВ — overlay
      body: _fewMovies
          ? content
          : Stack(
              children: [
                content,
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
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
