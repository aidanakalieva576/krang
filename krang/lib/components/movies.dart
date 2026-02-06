import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class MovieSection extends StatefulWidget {
  final String title;
  final String typeFilter;
  final String searchQuery;

  const MovieSection({
    super.key,
    required this.title,
    required this.typeFilter,
    required this.searchQuery,
  });

  @override
  State<MovieSection> createState() => _MovieSectionState();
}

class _MovieSectionState extends State<MovieSection> {
  Future<List<Map<String, dynamic>>>? _moviesFuture;

  // Храним полный список, который пришёл с сервера
  List<Map<String, dynamic>> _allMovies = [];

  // ✅ собираем URL с учетом фильтра
  String _getApiUrl() {
    const base = 'http://localhost:8080/api/public/movies';

    String endpoint;
    switch (widget.title.toLowerCase()) {
      case 'popular right now':
        endpoint = 'popular';
        break;
      case 'watching right now':
        endpoint = 'watching-now';
        break;
      case 'new':
        endpoint = 'new';
        break;
      case 'coming soon':
        endpoint = 'coming-soon';
        break;
      default:
        endpoint = '';
        break;
    }

    final type = widget.typeFilter;
    final typeParam = (type == 'All' || type.isEmpty) ? '' : '?type=$type';

    if (endpoint.isEmpty) return '$base$typeParam';
    return '$base/$endpoint$typeParam';
  }

  Future<List<Map<String, dynamic>>> _fetchMovies() async {
    final urlStr = _getApiUrl();
    debugPrint(
      "🎬 MovieSection '${widget.title}' type='${widget.typeFilter}' -> GET $urlStr",
    );

    final url = Uri.parse(urlStr);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      final movies = data.cast<Map<String, dynamic>>();

      // сохраняем полный список
      _allMovies = movies;

      debugPrint("🎬 status=200 moviesCount=${movies.length}");
      return movies;
    } else {
      throw Exception(
        'Failed to load movies: ${response.statusCode} ${response.body}',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _moviesFuture = _fetchMovies();
  }

  // ✅ если меняется фильтр (или заголовок секции) — грузим заново
  @override
  void didUpdateWidget(covariant MovieSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    final typeChanged = oldWidget.typeFilter != widget.typeFilter;
    final sectionChanged = oldWidget.title != widget.title;

    if (typeChanged || sectionChanged) {
      setState(() {
        _moviesFuture = _fetchMovies();
      });
      return;
    }

    // если поменялся только searchQuery — НЕ делаем запрос, просто перерисовываем
    if (oldWidget.searchQuery != widget.searchQuery) {
      setState(() {});
    }
  }

  // ✅ фильтрация по поиску (на фронте)
  List<Map<String, dynamic>> _applySearch(List<Map<String, dynamic>> movies) {
    final q = widget.searchQuery.trim().toLowerCase();
    if (q.isEmpty) return movies;

    return movies.where((m) {
      final title = (m['title'] ?? '').toString().toLowerCase();
      final category = (m['category'] ?? '').toString().toLowerCase();
      return title.contains(q) || category.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _moviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 12, bottom: 12),
            child: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // если snapshot.data null, берём то что сохранили
        final baseMovies = snapshot.data ?? _allMovies;
        final movies = _applySearch(baseMovies);

        // Заголовок секции показываем всегда
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // пусто вообще (на сервере нет)
            if (baseMovies.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'No movies in ${widget.title}',
                  style: const TextStyle(color: Colors.grey),
                ),
              )
            // есть фильмы, но поиск их отфильтровал
            else if (movies.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'No results for "${widget.searchQuery.trim()}"',
                  style: const TextStyle(color: Colors.white70),
                ),
              )
            // есть что показать
            else
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  itemCount: movies.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    final thumb = (movie['thumbnail_url'] ?? '').toString();

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/movie_details',
                          arguments: {'movieId': movie['id']},
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 130,
                          height: 200,
                          color: const Color(0xFF2C2C2C),
                          child: thumb.isEmpty
                              ? const Icon(Icons.image, color: Colors.white24, size: 40)
                              : Image.network(
                            thumb,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
