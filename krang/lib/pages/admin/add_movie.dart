import 'dart:io';
import 'dart:ui';
import 'dart:convert'; // 👈 добавь это
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddMoviePage extends StatefulWidget {
  const AddMoviePage({super.key});

  @override
  State<AddMoviePage> createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  int selectedRating = 0;

  // ✅ Тип (Movie / Series)
  String? selectedType;

  // ✅ Жанры с ID
  final List<Map<String, dynamic>> allGenres = [
    {"id": 1, "name": "Action"},
    {"id": 2, "name": "Comedy"},
    {"id": 3, "name": "Drama"},
    {"id": 4, "name": "Horror"},
    {"id": 5, "name": "Sci-Fi"},
    {"id": 6, "name": "Romance"},
    {"id": 7, "name": "Thriller"},
    {"id": 8, "name": "Fantasy"},
    {"id": 9, "name": "Adventure"},
    {"id": 10, "name": "Animation"},
    {"id": 11, "name": "Documentary"},
    {"id": 12, "name": "Crime"},
    {"id": 13, "name": "Mystery"},
    {"id": 14, "name": "War"},
    {"id": 15, "name": "Western"},
    {"id": 16, "name": "Biography"},
    {"id": 17, "name": "Music"},
    {"id": 18, "name": "Sport"},
    {"id": 19, "name": "Family"},
    {"id": 20, "name": "History"},
  ];

  Map<String, dynamic>? selectedGenre;
  File? selectedImage;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController platformController = TextEditingController();
  final TextEditingController directorController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const cloudName = "djmrfjkki"; // 👈 твой cloud name
    const uploadPreset = "ml_default"; // 👈 или свой, если создавал

    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final request = http.MultipartRequest("POST", url)
      ..fields["upload_preset"] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath("file", imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = json.decode(await response.stream.bytesToString());
      return responseData["secure_url"];
    } else {
      print("❌ Cloudinary upload failed: ${response.statusCode}");
      return null;
    }
  }

  Future<void> submitMovie() async {
    print('title: ${nameController.text}');
    print('desc: ${descriptionController.text}');
    print('year: ${yearController.text}');
    print('genre: $selectedGenre');
    print('type: $selectedType');

    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        yearController.text.isEmpty ||
        selectedGenre == null ||
        selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill all required fields")),
      );
      return;
    }

    String? imageUrl;

    if (selectedImage != null) {
      imageUrl = await uploadImageToCloudinary(selectedImage!);
    }

    if (imageUrl == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("⚠️ Image upload failed")));
      return;
    }

    final url = Uri.parse("http://localhost:8080/api/admin/movies");

    final body = json.encode({
      "title": nameController.text.trim(),
      "description": descriptionController.text.trim(),
      "releaseYear": int.tryParse(yearController.text.trim()) ?? 0,
      "type": selectedType,
      "categoryId": selectedGenre!['id'],
      "thumbnailUrl": imageUrl,
      "videoUrl": "string",
      "trailerUrl": "string",
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(
        'jwt_token',
      ); // 🔒 вставь сюда реальный токен админа

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // 👈 добавили токен
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Movie added successfully!")),
        );
        Navigator.pop(context);
      } else {
        print("❌ Error: ${response.statusCode} - ${response.body}");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("❌ Error: ${response.body}")));
      }
    } catch (e) {
      print("❌ Exception: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Failed to add movie: $e")));
    }
  }

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
                    final isSelected = selectedGenre?['id'] == genre['id'];
                    return ListTile(
                      title: Text(
                        "${genre['name']} (${genre['id']})",
                        style: TextStyle(
                          color: isSelected ? Colors.white54 : Colors.white,
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

                    // 📸 Фото
                    GestureDetector(
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

                    // 🎭 Жанр (только один)
                    // 🎭 Жанр (только один)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        if (selectedGenre != null)
                          GestureDetector(
                            onTap:
                                _showGenreSelector, // 👈 теперь нажимаем на жанр, чтобы поменять
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2D2F3E),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${selectedGenre!['name']} (${selectedGenre!['id']})",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: Colors.white54,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (selectedGenre ==
                            null) // 👈 плюс показывается только если жанр не выбран
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

                    // 🎬 Тип (Movie / Series)
                    // 🎬 Тип (Movie / Series)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Type",
                          style: TextStyle(
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
                            border: Border.all(color: Color(0xFF414553)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              alignment: Alignment
                                  .centerLeft, // 👈 Выровнено по левому краю
                              dropdownColor: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(
                                15,
                              ), // 👈 Закруглённые углы
                              value: selectedType,
                              hint: const Text(
                                "Select type",
                                style: TextStyle(color: Colors.white54),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: "MOVIE",
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.movie,
                                        color: Colors.white70,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Movie",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: "SERIES",
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.tv,
                                        color: Colors.white70,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Series",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => selectedType = value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 📝 Остальные поля
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
                      onTap: submitMovie,
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
