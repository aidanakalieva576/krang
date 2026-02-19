import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/search.dart';
import '../../components/navbar_admin.dart';
import 'add_movie.dart';
import '../../components/admin/movie_card_admin.dart';
import '../admin/edit_movie.dart';
import 'package:krang/api/api_config.dart';

class ContentItem {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String category;
  final bool isHidden;

  const ContentItem({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.category,
    required this.isHidden,
  });

  ContentItem copyWith({
    String? id,
    String? title,
    String? thumbnailUrl,
    String? category,
    bool? isHidden,
  }) {
    return ContentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      category: category ?? this.category,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}



class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({Key? key}) : super(key: key);

  @override
  State<HomePageAdmin> createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  String selectedCategory = 'All';
  String _searchQuery = '';

  List<ContentItem> _contentItems = [];
  bool _isLoading = false;
  int _selectedIndex = 0;

  final List<String> _categories = ['Horrors', 'Action', 'Comedy', 'Drama'];

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<void> _fetchMovies() async {
    setState(() => _isLoading = true);

    try {
      final token = await _getToken();
      if (token == null) {
        debugPrint('⚠️ Токен не найден. Пользователь не авторизован.');
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/movies'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('GET movies status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        setState(() {
          _contentItems = data.map<ContentItem>((movie) {
            return ContentItem(
              id: movie['id'].toString(),
              title: (movie['title'] ?? '').toString(),
              thumbnailUrl: (movie['thumbnail_url'] ?? '').toString(),
              category: (movie['category_id'] ?? '').toString(),
              isHidden: movie['is_hidden'] == true,
            );
          }).toList();
        });
      } else {
        debugPrint('❌ Ошибка загрузки фильмов: ${response.statusCode}');
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint('❌ Ошибка подключения: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ContentItem> get _filteredContent {
    final q = _searchQuery.trim().toLowerCase();

    return _contentItems.where((item) {
      final matchesSearch = q.isEmpty || item.title.toLowerCase().contains(q);
      final matchesCategory =
          selectedCategory == 'All' || item.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ..._categories];

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

                  Search(
                    onChanged: (query) {
                      setState(() => _searchQuery = query);
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = selectedCategory == cat;

                        return GestureDetector(
                          onTap: () => setState(() => selectedCategory = cat),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.grey[850],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

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
                        onHide: () => _toggleHidden(item), // ✅ ВОТ ЭТОГО НЕ ХВАТАЛО
                      );
                    }).toList(),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavbarAdmin(
              selectedIndex: _selectedIndex,
              onItemTapped: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewContentCard() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddMoviePage()),
        );
        _fetchMovies();
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
    debugPrint('Просмотр: ${item.title}');
  }

  void _editContent(ContentItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMovieScreen(movieId: int.parse(item.id)),
      ),
    );
    _fetchMovies();
  }

  Future<void> _toggleHidden(ContentItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      debugPrint('⚠️ Токен не найден. Нельзя скрыть.');
      return;
    }

    final newHidden = !item.isHidden;

    // 1) Сразу обновляем UI (без ожидания сервера)
    setState(() {
      final idx = _contentItems.indexWhere((x) => x.id == item.id);
      if (idx != -1) {
        _contentItems[idx] = _contentItems[idx].copyWith(isHidden: newHidden);
      }
    });
    final path = newHidden ? 'hide' : 'unhide';

    try {
      // 2) Запрос на сервер
      final res = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/movies/${item.id}/$path'),
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('HIDE status: ${res.statusCode}');
      debugPrint('HIDE body: ${res.body}');

      // 3) Если сервер ответил ошибкой — откатываемся к правде
      if (!(res.statusCode >= 200 && res.statusCode < 300)) {
        await _fetchMovies();
        return;
      }

      // 4) Если сервер возвращает JSON как в Postman: {"is_hidden": true, "id": 6}
      // Подстрахуемся и синхронизируем UI по серверу
      if (res.body.isNotEmpty) {
        final body = json.decode(res.body);

        if (body.containsKey('is_hidden')) {
          final serverHidden = body['is_hidden'] == true;
          setState(() {
            final idx = _contentItems.indexWhere((x) => x.id == item.id);
            if (idx != -1) {
              _contentItems[idx] =
                  _contentItems[idx].copyWith(isHidden: serverHidden);
            }
          });
        }
      }

    } catch (e) {
      debugPrint('❌ Ошибка скрытия: $e');
      await _fetchMovies();
    }
  }


  void _deleteContent(ContentItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2E2E2E),
        title: const Text('Confirm delete', style: TextStyle(color: Colors.white)),
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
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final token = await _getToken();
    if (token == null) return;

    setState(() {
      _contentItems.removeWhere((i) => i.id == item.id);
    });

    try {
      final res = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/movies/${item.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('DELETE status: ${res.statusCode}');
      debugPrint('DELETE body: ${res.body}');

      await _fetchMovies();
    } catch (e) {
      debugPrint('❌ Ошибка удаления: $e');
      await _fetchMovies();
    }
  }
}
