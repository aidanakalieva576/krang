import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class MovieSection extends StatefulWidget {
  final String title;

  // ✅ ДОБАВИЛИ: фильтр типа ('All' | 'MOVIE' | 'SERIES')
  final String typeFilter;

  const MovieSection({
    super.key,
    required this.title,
    required this.typeFilter,
  });

  @override
  State<MovieSection> createState() => _MovieSectionState();
}

class _MovieSectionState extends State<MovieSection> {
  Future<List<Map<String, dynamic>>>? _moviesFuture;

  // ✅ собираем URL с учетом фильтра
  String _getApiUrl() {
    final base = 'http://172.20.10.4:8080/api/public/movies';

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

  Future<List<Map<String, dynamic>>> fetchMovies() async {
    final urlStr = _getApiUrl();
    debugPrint(
      "🎬 MovieSection '${widget.title}' type='${widget.typeFilter}' -> GET $urlStr",
    );

    final url = Uri.parse(urlStr);
    final response = await http.get(url);

    debugPrint("🎬 status=${response.statusCode} body=${response.body}");

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      debugPrint("🎬 moviesCount=${data.length}");
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception(
        'Failed to load movies: ${response.statusCode} ${response.body}',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _moviesFuture = fetchMovies();
  }

  // ✅ ВАЖНО: если фильтр изменился — перезагружаем
  @override
  void didUpdateWidget(covariant MovieSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.typeFilter != widget.typeFilter) {
      setState(() {
        _moviesFuture = fetchMovies();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_moviesFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _moviesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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

        final movies = snapshot.data ?? [];

        if (movies.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No movies in ${widget.title}',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

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
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 16),
                itemCount: movies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final movie = movies[index];
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
                      child: Image.network(
                        movie['thumbnail_url'] ?? '',
                        width: 130,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50,
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
