import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/search.dart';
import '../../components/navbar_admin.dart';
import 'add_movie.dart';
import '../../components/admin/movie_card_admin.dart';
import '../admin/edit_movie.dart'; // ✅ правильный импорт

class ContentItem {
  final String id;
  final String title;
  final String thumbnail_url;
  final String category;
  final bool is_hidden;

  ContentItem({
    required this.id,
    required this.title,
    required this.thumbnail_url,
    required this.category,
    required this.is_hidden,
  });
}

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({Key? key}) : super(key: key);

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  List<ContentItem> _contentItems = [];
  bool _isLoading = false;
  int _selectedIndex = 0;

  final List<String> _categories = ['Horrors', 'Action', 'Comedy', 'Drama'];

  Future<void> _fetchMovies() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        print('⚠️ Токен не найден. Пользователь не авторизован.');
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8080/api/admin/movies'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _contentItems = data.map((movie) {
            return ContentItem(
              id: movie['id'].toString(),
              title: movie['title'] ?? '',
              thumbnail_url: movie['thumbnail_url'] ?? '',
              category: movie['category_id']?.toString() ?? '',
              is_hidden: movie['is_hidden'] ?? false,
            );
          }).toList();
        });
      } else {
        print('❌ Ошибка загрузки фильмов: ${response.statusCode}');
        print(response.body);
      }
    } catch (e) {
      print('❌ Ошибка подключения: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ContentItem> get _filteredContent {
    return _contentItems.where((item) {
      final matchesCategory =
          selectedCategory == 'All' || item.category == selectedCategory;
      final matchesSearch =
          _searchController.text.isEmpty ||
          item.title.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 16),
                  const Search(),
                  const SizedBox(height: 24),
                  _buildCategoriesSection(),
                  const SizedBox(height: 24),
                  _buildAddNewContentCard(),
                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else if (_filteredContent.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text(
                          'No content found',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  else
                    ..._filteredContent.map((item) {
                      return MovieCardAdmin(
                        item: item,
                        onView: () => _viewContent(item),
                        onEdit: () => _editContent(item),
                        onDelete: () => _deleteContent(item),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),

          // ✅ Нижний навбар
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavbarAdmin(
              selectedIndex: _selectedIndex,
              onItemTapped: (index) {
                setState(() => _selectedIndex = index);
                // можно добавить переход между страницами
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = ['All', ..._categories];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = selectedCategory == categories[index];
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = categories[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddNewContentCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddMoviePage()),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0x80414553),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0x80414553),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade700, width: 1),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons_admin/camera.png',
                  width: 40,
                  height: 40,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Add new content',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 48,
              height: 48,
              child: Image.asset(
                'assets/icons_admin/plus.png',
                width: 40,
                height: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewContent(ContentItem item) {
    print('Просмотр: ${item.title}');
  }

  void _editContent(ContentItem item) {
    print('✏️ Нажали редактирование: ${item.title}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMovieScreen(
          movieId: int.parse(item.id), // ✅ передаём правильный тип
        ),
      ),
    );
  }

  void _deleteContent(ContentItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E2E),
        title: const Text(
          'Confirm delete',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${item.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _contentItems.removeWhere((i) => i.id == item.id);
      });
      print('Удалено: ${item.title}');
    }
  }
}
