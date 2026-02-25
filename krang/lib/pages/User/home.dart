import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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
  String _searchQuery = "";
  int _selectedIndex = 0;
  String _selectedType = 'All';

  // --- Search results state ---
  Timer? _debounce;
  bool _isSearching = false;
  List<Map<String, dynamic>> _allMoviesCache = [];
  List<Map<String, dynamic>> _searchResults = [];

  static const String _baseUrl = 'http://172.20.10.4:8080';

  final List<String> carouselImages = const [
    'assets/icons_user/the_woman_in_cabin_10.png',
    'assets/icons_user/pickup.png',
    'assets/icons_user/play_dirty.png',
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // Загружаем все фильмы 1 раз (кэш)
  Future<void> _ensureAllMoviesLoaded() async {
    if (_allMoviesCache.isNotEmpty) return;

    final res = await http.get(Uri.parse('$_baseUrl/api/public/movies'));
    if (res.statusCode != 200) {
      throw Exception("Failed to load movies: ${res.statusCode} ${res.body}");
    }
    final List data = jsonDecode(res.body);
    _allMoviesCache = data.cast<Map<String, dynamic>>();
  }

  // Сортировка как ты просила: exact -> startsWith -> contains
  List<Map<String, dynamic>> _filterAndSortMovies(
      List<Map<String, dynamic>> movies,
      String query,
      ) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final exact = <Map<String, dynamic>>[];
    final starts = <Map<String, dynamic>>[];
    final contains = <Map<String, dynamic>>[];

    for (final m in movies) {
      final title = (m['title'] ?? '').toString();
      final t = title.toLowerCase();

      if (t == q) {
        exact.add(m);
      } else if (t.startsWith(q)) {
        starts.add(m);
      } else if (t.contains(q)) {
        contains.add(m);
      }
    }

    // Если есть точное совпадение — показываем ТОЛЬКО его (как ты сказала)
    if (exact.isNotEmpty) return exact;

    // иначе показываем starts + contains
    return [...starts, ...contains];
  }

  void _onSearchChanged(String text) {
    debugPrint("🔍 SEARCH: $text");

    setState(() {
      _searchQuery = text;
    });

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final q = _searchQuery.trim();

      // пустой запрос -> скрываем результаты и показываем обычные секции
      if (!mounted) return;
      if (q.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }

      setState(() => _isSearching = true);

      try {
        await _ensureAllMoviesLoaded();
        final filtered = _filterAndSortMovies(_allMoviesCache, q);

        if (!mounted) return;
        setState(() {
          _searchResults = filtered;
          _isSearching = false;
        });
      } catch (e) {
        debugPrint("❌ Search error: $e");
        if (!mounted) return;
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  bool get _showSearchResults => _searchQuery.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    const double sectionGap = 40;

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
                  Search(onChanged: _onSearchChanged),
                  const SizedBox(height: 12),

                  // ✅ вот тут: если есть запрос — показываем результаты списком
                  if (_showSearchResults) ...[
                    _buildSearchResultsBlock(),
                    const SizedBox(height: 24),
                  ] else ...[
                    // ✅ обычная главная
                    const SizedBox(height: 8),
                    _buildSectionTitle("For you"),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
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

                    CategorySection(
                      selected: _selectedType,
                      onSelected: (v) => setState(() => _selectedType = v),
                    ),

                    const SizedBox(height: 32),

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
                ],
              ),
            ),
          ),

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

  Widget _buildSearchResultsBlock() {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text(
          "No results",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Results",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w200,
          ),
        ),
        const SizedBox(height: 10),

        // ✅ Списком
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _searchResults.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final movie = _searchResults[index];
            final title = (movie['title'] ?? '').toString();
            final category = (movie['category'] ?? '').toString();
            final thumb = (movie['thumbnail_url'] ?? '').toString();

            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/movie_details',
                  arguments: {'movieId': movie['id']},
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        thumb,
                        width: 56,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 56,
                          height: 76,
                          color: Colors.white12,
                          child: const Icon(Icons.broken_image,
                              color: Colors.white54),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white54),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
