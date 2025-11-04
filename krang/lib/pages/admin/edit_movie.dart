import 'package:flutter/material.dart';

class EditMovieScreen extends StatefulWidget {
  const EditMovieScreen({super.key});

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  // Данные для редактирования
  String title = "The Lego Movie";
  int rating = 4;
  List<String> tags = ["Fantasy", "Drama", "Action", "Animation"];
  String description =
      'An ordinary LEGO construction worker, thought to be the prophesied as "special", is recruited to join a quest to stop an evil tyrant from gluing the LEGO universe into eternal stasis.';
  String year = "2014";
  String platform = "The Warner Animation Group";
  String director = "Pascal Charron, Arnaud Delord, Berth Moncorgé";

  // Контроллеры
  final TextEditingController tagController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController platformController = TextEditingController();
  final TextEditingController directorController = TextEditingController();

  // Для хранения выбранной картинки
  String? movieImage = "assets/icons_user/lego_movie.jpeg";

  @override
  void initState() {
    super.initState();
    descriptionController.text = description;
    yearController.text = year;
    platformController.text = platform;
    directorController.text = director;
  }

  @override
  void dispose() {
    tagController.dispose();
    descriptionController.dispose();
    yearController.dispose();
    platformController.dispose();
    directorController.dispose();
    super.dispose();
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
            )
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
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        image: AssetImage(movieImage!),
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
                                  borderSide:
                                  BorderSide(color: Colors.white38),
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
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel',
                                    style: TextStyle(color: Colors.white70)),
                              ),
                              TextButton(
                                onPressed: () {
                                  addTag();
                                  Navigator.pop(context);
                                },
                                child: const Text('Add',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8, bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
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
                  )
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

              // Нижние кнопки с изображениями
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        year = yearController.text.trim();
                        platform = platformController.text.trim();
                        director = directorController.text.trim();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Changes saved!')),
                      );
                    },
                    child: Image.asset(
                      'assets/icons_admin/done.png',   // локальная галочка
                      width: 40,                        // тонкая иконка
                      height: 40,
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/icons_admin/Cross.png',  // локальный крестик
                      width: 42,                        // ещё чуть меньше
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
