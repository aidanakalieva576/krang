import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class MovieSection extends StatefulWidget {
  final String title;
  const MovieSection({super.key, required this.title});

  @override
  State<MovieSection> createState() => _MovieSectionState();
}

class _MovieSectionState extends State<MovieSection> {
  Future<List<Map<String, dynamic>>>? _moviesFuture;

  // 🔹 Определяем URL для конкретного раздела
  String _getApiUrl() {
    final base = 'http://192.168.123.35:8080/api/public/movies';

    switch (widget.title.toLowerCase()) {
      case 'popular right now':
        return '$base/popular';
      case 'watching right now':
        return '$base/watching-now';
      case 'new':
        return '$base/new';
      case 'coming soon':
        return '$base/coming-soon';
      default:
        return '$base';
    }
  }

  Future<List<Map<String, dynamic>>> fetchMovies() async {
    final url = Uri.parse(_getApiUrl());
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load movies: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    _moviesFuture = fetchMovies();
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
              '❌ Error: ${snapshot.error}',
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
                      Navigator.pushNamed(context, '/movie_details');
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
