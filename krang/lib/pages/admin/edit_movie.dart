import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

File? pickedThumbnail;
File? pickedVideo;

class EditMovieScreen extends StatefulWidget {
  final int movieId; // ← принимаем ID фильма

  const EditMovieScreen({super.key, required this.movieId});

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  // Данные
  String title = "";
  int rating = 0;
  List<String> tags = [];
  String description = "";
  String year = "";
  String platform = "";
  String director = "";
  String? movieImage;

  // Контроллеры
  final TextEditingController tagController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController platformController = TextEditingController();
  final TextEditingController directorController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMovieData();
  }

  Future<void> saveMovieMultipart() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) throw Exception('No token');

    final uri = Uri.parse(
      'http://172.20.10.4:8080/api/admin/movies/${widget.movieId}',
    );

    final request = http.MultipartRequest('PUT', uri);

    request.headers['Authorization'] = 'Bearer $token';
    // Content-Type НЕ ставь вручную — MultipartRequest сам поставит boundary

    // обязательные поля (как у тебя в бэке @RequestParam без required=false)
    request.fields['title'] = title;
    request.fields['description'] = descriptionController.text.trim();
    request.fields['releaseYear'] = yearController.text.trim();
    request.fields['platform'] = platformController.text.trim();
    request.fields['director'] = directorController.text.trim();
    request.fields['type'] = 'MOVIE'; // или SERIES (как у тебя)
    request.fields['categoryId'] = '1'; // подставь реальный id категории

    // optional thumbnail
    if (pickedThumbnail != null) {
      request.files.add(
        await http.MultipartFile.fromPath('thumbnail', pickedThumbnail!.path),
      );
    }

    // optional video (только MOVIE)
    if (pickedVideo != null) {
      request.files.add(
        await http.MultipartFile.fromPath('video', pickedVideo!.path),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    print('PUT multipart status: ${response.statusCode}');
    print('body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('✅ Changes saved!')));
    } else {
      throw Exception('Save failed: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> loadMovieData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('http://172.20.10.4:8080/api/admin/movies/${widget.movieId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 GET /movies/${widget.movieId}');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          title = data['title'] ?? '';
          description = data['description'] ?? '';
          year = (data['releaseYear'] ?? '').toString();
          platform = data['platform'] ?? '';
          director = data['director'] ?? '';
          movieImage = data['thumbnailUrl'];
          tags = [if (data['category'] != null) data['category']];
          descriptionController.text = description;
          yearController.text = year;
          platformController.text = platform;
          directorController.text = director;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load movie (${response.statusCode})');
      }
    } catch (e) {
      debugPrint("❌ Error loading movie: $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load movie data")),
      );
    }
  }

  void addTag() {
    final newTag = tagController.text.trim();
    if (newTag.isNotEmpty && !tags.contains(newTag)) {
      setState(() {
        tags.add(newTag);
        tagController.clear();
      });
    }
  }

  void removeTag(String tag) {
    setState(() {
      tags.remove(tag);
    });
  }

  Widget buildTag(String tag) {
    final yellowTags = ["Fantasy"];
    final greyTags = ["Drama", "Action", "Animation"];
    final isYellow = yellowTags.contains(tag);
    final isGrey = greyTags.contains(tag);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: isYellow
            ? const Color(0xFFFFD700)
            : isGrey
            ? const Color(0xFF2D2F41)
            : Colors.grey.shade700,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: TextStyle(
              color: isYellow ? Colors.black : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!isYellow)
            GestureDetector(
              onTap: () => removeTag(tag),
              child: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.close, size: 16, color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildStar(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          rating = index + 1;
        });
      },
      child: Icon(
        index < rating ? Icons.star : Icons.star_border,
        color: Colors.yellow[700],
        size: 28,
      ),
    );
  }

  Widget buildInfoInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2D2F41),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Верхняя панель
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 16),

              // Картинка с камерой
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      image: movieImage != null
                          ? DecorationImage(
                              image: NetworkImage(movieImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  if (movieImage == null)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 12,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 28,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 18),

              // Название
              Stack(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2.5
                        ..color = Colors.white.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Рейтинг звезд
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => buildStar(index)),
              ),
              const SizedBox(height: 12),

              // Теги
              Wrap(
                children: [
                  ...tags.map(buildTag).toList(),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            backgroundColor: const Color(0xFF121212),
                            title: const Text(
                              'Add Tag',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: TextField(
                              controller: tagController,
                              autofocus: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'New tag',
                                hintStyle: TextStyle(color: Colors.white54),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white38),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              onSubmitted: (_) {
                                addTag();
                                Navigator.pop(context);
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  addTag();
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Add',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8, bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2F41),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "+",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Description",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white70),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF2D2F41),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  description = val;
                },
              ),
              const SizedBox(height: 18),

              // Year, Platform, Director
              buildInfoInput("Year of production", yearController),
              const SizedBox(height: 12),
              buildInfoInput("Platform", platformController),
              const SizedBox(height: 12),
              buildInfoInput("Director", directorController),
              const SizedBox(height: 24),

              // Нижние кнопки
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      try {
                        await saveMovieMultipart();
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('❌ $e')));
                      }
                    },

                    child: Image.asset(
                      'assets/icons_admin/done.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/icons_admin/Cross.png',
                      width: 42,
                      height: 42,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}