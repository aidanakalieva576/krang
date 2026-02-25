import 'dart:convert';
import 'dart:math';

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

  // ⚠️ Подставь реальную высоту твоего CustomBottomNavBar (примерно 90-100)
  static const double _navBarHeight = 92;

  static const String _placeholderPoster =
      'https://via.placeholder.com/300x450.png?text=Add+to+Favorites';

  @override
  void initState() {
    super.initState();
    debugPrint("🔥 MY MOVIES PAGE OPENED 🔥");
    _fetchFavorites();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  int get _itemsToRender => max(3, _favorites.length);

  Future<void> _fetchFavorites() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
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
        debugPrint("❌ Ошибка сервера: ${res.statusCode} ${res.body}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Favorites load error: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Widget _emptyCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MovieCard(
        imagePath: _placeholderPoster,
        title: "No favorites yet",
        subtitle: "Add movies to favorites",
        seasons: "",
        onTap: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),

      // ✅ ВАЖНО: navBar overlay, а контент сам с отступом снизу
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: MoviesHeader()),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                SliverToBoxAdapter(
                  child: Padding(
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
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                if (_isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          if (index >= _favorites.length) {
                            return _emptyCard();
                          }

                          final movie = _favorites[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: MovieCard(
                              imagePath:
                              movie['thumbnail_url'] ?? _placeholderPoster,
                              title: movie['title'] ?? 'Untitled',
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
                        },
                        childCount: _itemsToRender,
                      ),
                    ),
                  ),

                // ✅ всегда оставляем место снизу под overlay navbar
                SliverToBoxAdapter(
                  child: SizedBox(height: _navBarHeight + bottomSafe + 12),
                ),
              ],
            ),
          ),

          // ✅ Приклеенный навбар снизу
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
