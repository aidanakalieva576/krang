import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Model class for content items
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

  // // Sample data - replace with your actual data source
  // final List<ContentItem> _contentItems = [
  //   ContentItem(
  //     id: '1',
  //     title: 'The Smashing machine',
  //     imageUrl: 'assets/images/smashing_machine.jpg',
  //     category: 'Drama',
  //   ),
  //   ContentItem(
  //     id: '2',
  //     title: 'Arcane',
  //     imageUrl: 'assets/images/arcane.jpg',
  //     category: 'Action',
  //   ),
  //   ContentItem(
  //     id: '3',
  //     title: 'Oppenheimer',
  //     imageUrl: 'assets/images/oppenheimer.jpg',
  //     category: 'Drama',
  //   ),
  // ];
  List<ContentItem> _contentItems = [];
  bool _isLoading = false;

  Future<void> _fetchMovies() async {
    setState(() {
      _isLoading = true;
    });

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
      } else {
        print('Ошибка при загрузке: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка подключения: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final List<String> _categories = ['Horrors', 'Action', 'Comedy', 'Drama'];

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
            // Status bar area
            _buildStatusBar(),

            // Main content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const SizedBox(height: 16),

                  // Search bar
                  _buildSearchBar(),

                  const SizedBox(height: 24),

                  // Categories section
                  _buildCategoriesSection(),

                  const SizedBox(height: 24),

                  // Add new content card
                  _buildAddNewContentCard(),

                  const SizedBox(height: 16),

                  // Content list
                  // ..._filteredContent
                  //     .map((item) => _buildContentCard(item))
                  //     .toList(),
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

      // Bottom navigation bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '21:34',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.signal_cellular_4_bar,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.wifi, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Icon(Icons.battery_full, color: Colors.white, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search movies, series, shows...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 15,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((category) {
              final isSelected = selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildCategoryChip(category, isSelected),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = isSelected ? 'All' : category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5B5B6B) : const Color(0xFF2D2D3A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewContentCard() {
    return GestureDetector(
      onTap: () {
        _showAddContentDialog();
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D3A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 120,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3D3D4A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.photo_camera_outlined,
                color: Colors.white.withOpacity(0.3),
                size: 48,
              ),
            ),

            // Text and add button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add new content',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D3D4A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(ContentItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Movie poster
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF3D3D4A),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFF3D3D4A),
                      child: const Icon(
                        Icons.movie,
                        color: Colors.white54,
                        size: 32,
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Title and actions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.remove_red_eye_outlined,
                        color: const Color(0xFF5B5B7E),
                        onTap: () => _viewContent(item),
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.edit_outlined,
                        color: const Color(0xFF5B7E5B),
                        onTap: () => _editContent(item),
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        color: const Color(0xFF7E5B5B),
                        onTap: () => _deleteContent(item),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D3A),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.movie_outlined, true),
          _buildNavItem(Icons.people_outline, false),
          _buildNavItem(Icons.trending_up_outlined, false),
          _buildNavItem(Icons.person_outline, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
        size: 28,
      ),
    );
  }

  // Action methods
  void _showAddContentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D3A),
        title: const Text(
          'Add New Content',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This would open a form to add new movie/series content.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Add your content addition logic here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B5B7E),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _viewContent(ContentItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing: ${item.title}'),
        backgroundColor: const Color(0xFF5B5B7E),
      ),
    );
    // Navigate to content details page
  }

  void _editContent(ContentItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing: ${item.title}'),
        backgroundColor: const Color(0xFF5B7E5B),
      ),
    );
    // Navigate to edit page
  }

  void _deleteContent(ContentItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2D3A),
        title: const Text(
          'Delete Content',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${item.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _contentItems.removeWhere((i) => i.id == item.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted: ${item.title}'),
                  backgroundColor: const Color(0xFF7E5B5B),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7E5B5B),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
