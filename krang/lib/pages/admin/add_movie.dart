import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddMoviePage extends StatefulWidget {
  const AddMoviePage({super.key});

  @override
  State<AddMoviePage> createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  int selectedRating = 0;
  final List<String> allGenres = [
    'Action',
    'Comedy',
    'Drama',
    'Horror',
    'Sci-Fi',
    'Romance',
    'Thriller',
    'Fantasy',
    'Adventure',
    'Animation',
  ];

  final List<String> selectedGenres = [];
  File? selectedImage;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController platformController = TextEditingController();
  final TextEditingController directorController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  void _showGenreSelector() {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Genre',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: allGenres.length,
                  itemBuilder: (context, index) {
                    final genre = allGenres[index];
                    final alreadyAdded = selectedGenres.contains(genre);
                    return ListTile(
                      title: Text(
                        genre,
                        style: TextStyle(
                          color: alreadyAdded ? Colors.white54 : Colors.white,
                        ),
                      ),
                      onTap: alreadyAdded
                          ? null
                          : () {
                              setState(() {
                                selectedGenres.add(genre);
                              });
                              Navigator.pop(context);
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // 🔹 Верхняя зона под постер
          Container(
            height: 280,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2C2E49), Color(0xFF1A1A1A)],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 🔙 Назад
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Image.asset(
                          'assets/icons_admin/line_to_back.png',
                          width: 36,
                          height: 36,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // 📸 Фото фильма
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (selectedImage == null)
                              ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Image.asset(
                                  'assets/icons_admin/camera_for_edit.png',
                                  width: 130,
                                  height: 130,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            if (selectedImage != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  selectedImage!,
                                  width: 130,
                                  height: 130,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            if (selectedImage == null)
                              Image.asset(
                                'assets/icons_admin/camera_for_edit.png',
                                width: 58,
                                height: 58,
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Название
                    TextField(
                      controller: nameController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'Name',
                        hintStyle: TextStyle(
                          color: Colors.white70,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ⭐️ Рейтинг
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedRating = starIndex),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Image.asset(
                              selectedRating >= starIndex
                                  ? 'assets/icons_admin/full_star.png'
                                  : 'assets/icons_admin/star.png',
                              width: 28,
                              height: 28,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 25),

                    // 🎭 Жанры (без иконок)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final genre in selectedGenres)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D2F3E),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              genre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: _showGenreSelector,
                          child: Image.asset(
                            'assets/icons_admin/plus.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    buildFieldBlock(
                      "Description",
                      descriptionController,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    buildFieldBlock("Year of production", yearController),
                    const SizedBox(height: 10),
                    buildFieldBlock("Platform", platformController),
                    const SizedBox(height: 10),
                    buildFieldBlock("Director", directorController),

                    const SizedBox(height: 50),

                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        'assets/icons_admin/done.png',
                        width: 70,
                        height: 70,
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFieldBlock(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.left,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF414553)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: '...',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
