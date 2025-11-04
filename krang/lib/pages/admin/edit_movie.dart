import 'package:flutter/material.dart';

class EditMovieScreen extends StatefulWidget {
  const EditMovieScreen({super.key});

  @override
  State<EditMovieScreen> createState() => _EditMovieScreenState();
}

class _EditMovieScreenState extends State<EditMovieScreen> {
  String title = "The Lego Movie";
  int rating = 4;
  String? selectedGenre = "Fantasy"; // 🔹 Только один выбранный жанр
  List<String> allGenres = ["Fantasy", "Drama", "Action", "Animation", "Comedy", "Adventure"];

  String description =
      'An ordinary LEGO construction worker, thought to be the prophesied as "special", is recruited to join a quest to stop an evil tyrant from gluing the LEGO universe into eternal stasis.';
  String year = "2014";
  String platform = "The Warner Animation Group";
  String director = "Pascal Charron, Arnaud Delord, Berth Moncorgé";

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController platformController = TextEditingController();
  final TextEditingController directorController = TextEditingController();

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
    descriptionController.dispose();
    yearController.dispose();
    platformController.dispose();
    directorController.dispose();
    super.dispose();
  }

  Widget buildGenreTag(String genre) {
    bool isSelected = selectedGenre == genre;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGenre = genre;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700) : const Color(0xFF2D2F41),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          genre,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
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

  void showGenrePicker() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF121212),
          title: const Text(
            'Choose genre',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allGenres.length,
              itemBuilder: (context, index) {
                String genre = allGenres[index];
                return ListTile(
                  title: Text(
                    genre,
                    style: TextStyle(
                      color: genre == selectedGenre
                          ? Colors.amber
                          : Colors.white70,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedGenre = genre;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
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
              // 🔹 Верхняя панель
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

              // 🔹 Картинка фильма
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

              const SizedBox(height: 18),

              // 🔹 Название
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

              // 🔹 Рейтинг
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => buildStar(index)),
              ),
              const SizedBox(height: 12),

              // 🔹 Жанры
              Wrap(
                children: [
                  if (selectedGenre != null) buildGenreTag(selectedGenre!),
                  GestureDetector(
                    onTap: showGenrePicker,
                    child: Container(
                      margin: const EdgeInsets.only(right: 8, bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2), // меньше кнопка
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2F41),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "+",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 🔹 Description
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
              ),
              const SizedBox(height: 18),

              // 🔹 Остальные поля
              buildInfoInput("Year of production", yearController),
              const SizedBox(height: 12),
              buildInfoInput("Platform", platformController),
              const SizedBox(height: 12),
              buildInfoInput("Director", directorController),
              const SizedBox(height: 24),

              // 🔹 Нижние кнопки
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Changes saved!')),
                      );
                    },
                    child: Image.asset(
                      'assets/icons_admin/done.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
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
