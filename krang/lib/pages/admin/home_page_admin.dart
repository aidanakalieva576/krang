import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ✅ Импортируем компоненты
import 'package:krang/components/search.dart';
import 'package:krang/components/navbar_admin.dart';

// Модель данных
class ContentItem {
  final String id;
  final String title;
  final String imageUrl;
  final String category;

  ContentItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
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

  Future<void> _fetchMovies() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/movies'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _contentItems = data.map((movie) {
            return ContentItem(
              id: movie['id'].toString(),
              title: movie['title'] ?? '',
              imageUrl: movie['imageUrl'] ?? '',
              category: movie['category'] ?? '',
            );
          }).toList();
        });
      }
    } catch (e) {
      print('Ошибка подключения: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  final List<String> _categories = ['Horrors', 'Action', 'Comedy', 'Drama'];

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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 16),

                  // ✅ Используем компонент поиска
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
                      child: Text(
                        'No content found',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  else
                    ..._filteredContent
                        .map((item) => _buildContentCard(item))
                        .toList(),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),

      // ✅ Используем компонент Navbar
      bottomNavigationBar: NavbarAdmin(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() => _selectedIndex = index);
          // Здесь можно сделать переход на другие страницы
        },
      ),
    );
  }

  // Остальные методы (категории, карточки, действия) оставляем без изменений
  // --- Категории ---
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

  // --- Карточка добавления контента ---
  Widget _buildAddNewContentCard() {
    return GestureDetector(
      onTap: () {
        // позже добавим действие — открытие формы добавления контента
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0x80414553), // тёмно-серый фон карточки
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Левая часть — иконка фотоаппарата
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
                  'assets/icons_admin/camera.png', // путь к твоей иконке
                  width: 40,
                  height: 40,
                  color: Colors.grey.shade400,
                ),
              ),
            ),

            // Средняя часть — текст
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

            // Правая часть — кнопка с плюсом
            Container(
              width: 48,
              height: 48,
              child: Image.asset(
                'assets/icons_admin/plus.png', // путь к твоей иконке
                width: 40,
                height: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Карточка контента ---
  Widget _buildContentCard(ContentItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              image: item.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(item.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage('assets/placeholder.png'),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.visibility,
                          color: Colors.white70,
                          size: 22,
                        ),
                        onPressed: () => _viewContent(item),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blueAccent,
                          size: 22,
                        ),
                        onPressed: () => _editContent(item),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                          size: 22,
                        ),
                        onPressed: () => _deleteContent(item),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Действия ---
  void _viewContent(ContentItem item) {
    // например, откроем просмотр фильма
    print('Просмотр: ${item.title}');
  }

  void _editContent(ContentItem item) {
    // потом сделаем переход на страницу редактирования
    print('Редактирование: ${item.title}');
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
      // Здесь можно добавить запрос на сервер DELETE /api/movies/:id
      print('Удалено: ${item.title}');
    }
  }
}
