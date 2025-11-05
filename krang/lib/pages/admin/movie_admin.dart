import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class EditMoviePage extends StatefulWidget {
  final int movieId;

  const EditMoviePage({super.key, required this.movieId});

  @override
  State<EditMoviePage> createState() => _EditMoviePageState();
}

class _EditMoviePageState extends State<EditMoviePage> {
  double scrollOffset = 0.0;
  Map<String, dynamic>? movieData;
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchMovieDetails();
  }

  Future<void> fetchMovieDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/movies/${widget.movieId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '"Bearer $token"',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          movieData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error fetching movie: $e');
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double posterHeight = 280;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (isError || movieData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        body: const Center(
          child: Text(
            'Error loading movie 😢',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    final movie = movieData!;
    final title = movie['title'] ?? 'Unknown';
    final description = movie['description'] ?? 'No description available';
    final thumbnailUrl = movie['thumbnailUrl'] ?? '';
    final releaseYear = movie['releaseYear']?.toString() ?? '-';
    final director = movie['director'] ?? '-';
    final platform = movie['platform'] ?? '-';
    final categoryName = movie['category']?['name'] ?? '-';
    final rating = movie['rating'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          /// Фон-постер
          Positioned(
            top: -scrollOffset * 0.4,
            left: 0,
            right: 0,
            child: SizedBox(
              height: posterHeight + scrollOffset * 0.4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/icons_user/lego_movie.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xCC0F0F0F),
                          Color(0xFF0F0F0F),
                        ],
                        stops: [0.4, 0.75, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Контент
          SafeArea(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (scrollInfo is ScrollUpdateNotification) {
                  setState(() => scrollOffset = scrollInfo.metrics.pixels);
                }
                return false;
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Верхняя панель
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 16,
                        right: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Image.asset(
                              'assets/icons_admin/line_to_back.png',
                              width: 36,
                              height: 36,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showUploadForm(context),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/icons_admin/add_movie.png',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: posterHeight - 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            categoryName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "$releaseYear | $platform",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < (rating.round())
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Описание
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            description,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// Информация
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          buildInfoRow('Director', director),
                          const SizedBox(height: 10),
                          buildInfoRow('Platform', platform),
                          const SizedBox(height: 10),
                          buildInfoRow('Year', releaseYear),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🧩 Инфо-ряд
  static Widget buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 15),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Форма добавления/редактирования
  void _showUploadForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Upload form here',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
