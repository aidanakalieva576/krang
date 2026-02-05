import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MovieDetailPage extends StatefulWidget {
  final int movieId;

  const MovieDetailPage({super.key, required this.movieId});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  int currentRating = 4;
  double scrollOffset = 0.0;
  Map<String, dynamic>? movieData;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchMovieDetails();
  }

  Future<void> fetchMovieDetails() async {
    try {
      print('🧩 Загружаем фильм с ID: ${widget.movieId}');

      final response = await http.get(
        Uri.parse('http://localhost:8080/api/public/movies/${widget.movieId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          movieData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching movie details: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void _showReviewDialog() {
    int tempRating = currentRating;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Want to leave a rate?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Rate the movie:",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  bool filled = index < tempRating;
                  return GestureDetector(
                    onTap: () {
                      setState(() => tempRating = index + 1);
                      (context as Element).markNeedsBuild();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Image.asset(
                        filled
                            ? 'assets/icons_admin/full_star.png'
                            : 'assets/icons_admin/star.png',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Отмена",
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => currentRating = tempRating);
                Navigator.pop(context);
              },
              child: const Text(
                "Сохранить",
                style: TextStyle(
                  color: Color(0xFF94CAFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
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

    if (hasError || movieData == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(
          child: Text(
            'Ошибка загрузки данных ',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final movie = movieData!;
    final title = movie['title'] ?? 'Unknown';
    final description = movie['description'] ?? 'No description available.';
    final year = movie['release_year']?.toString() ?? '—';
    final director = movie['director'] ?? '—';
    final platform = movie['platform'] ?? '—';
    final category = movie['category'] ?? '';
    final thumbnail = movie['thumbnail_url'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -scrollOffset * 0.4,
            left: 0,
            right: 0,
            child: SizedBox(
              height: posterHeight + scrollOffset * 0.4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  thumbnail.isNotEmpty
                      ? Image.network(thumbnail, fit: BoxFit.cover)
                      : Container(color: Colors.grey.shade800),
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
                    /// Назад
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 16,
                        right: 16,
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset(
                          'assets/icons_admin/line_to_back.png',
                          width: 36,
                          height: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: posterHeight - 40),

                    /// Название и инфо
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
                            '$category · $platform',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              final filled = index < currentRating;
                              return GestureDetector(
                                onTap: _showReviewDialog,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  child: Image.asset(
                                    filled
                                        ? 'assets/icons_admin/full_star.png'
                                        : 'assets/icons_admin/star.png',
                                    width: 26,
                                    height: 26,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    /// Кнопка Watch
                    Center(
                      child: Container(
                        width: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFF465E90),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            final movieId = widget.movieId;
                            final title = (movie['title'] ?? 'Unknown')
                                .toString();
                            final videoUrl = (movie['video_url'] ?? '')
                                .toString();

                            if (videoUrl.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '⚠️ Видео пока недоступно для этого фильма.',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            Navigator.pushNamed(
                              context,
                              '/watch',
                              arguments: {
                                'movieId': movieId,
                                'title': title,
                                'videoUrl': videoUrl,
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Watch',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

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
                          const SizedBox(height: 24),
                          buildInfoRow('Year of production', year),
                          const SizedBox(height: 8),
                          buildInfoRow('Platform', platform),
                          const SizedBox(height: 8),
                          buildInfoRow('Director', director),
                          const SizedBox(height: 30),

                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22222A),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.favorite_border,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Добавлено в избранное ❤️'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
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
}
