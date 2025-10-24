import 'package:flutter/material.dart';
import '../../components/continue_watching.dart';
import '../../components/navbar.dart';

class ContinueWatchingScreen extends StatefulWidget {
  const ContinueWatchingScreen({super.key});

  @override
  State<ContinueWatchingScreen> createState() => _ContinueWatchingScreenState();
}

class _ContinueWatchingScreenState extends State<ContinueWatchingScreen> {
  int _selectedIndex =
      1; // например, это вторая вкладка (для "Continue Watching")

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // можно добавить навигацию при переключении
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'K-pop Demon Hunters',
        'image': 'assets/icons_user/kpop_demon_hunters.png',
        'progress': 0.8,
      },
      {
        'title': 'The Lovely Bones',
        'image': 'assets/icons_user/the_lovely_bones.png',
        'progress': 0.6,
      },
      {
        'title': 'Orange Is the New Black',
        'image': 'assets/icons_user/oitnb.png',
        'progress': 0.3,
      },
      {
        'title': 'BoJack Horseman',
        'image': 'assets/icons_user/the_lovely_bones.png',
        'progress': 0.5,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Основной контент
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  leading: const BackButton(color: Colors.white),
                  title: const Text(
                    'Continue Watching',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ContinueWatchingItem(
                          title: item['title'] as String,
                          imagePath: item['image'] as String,
                          progress: item['progress'] as double,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ✅ Навбар поверх
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}
