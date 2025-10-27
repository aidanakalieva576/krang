import 'package:flutter/material.dart';
import '../../components/continue_watching.dart';
import '../../components/navbar.dart';

class ContinueWatchingScreen extends StatefulWidget {
  const ContinueWatchingScreen({super.key});

  @override
  State<ContinueWatchingScreen> createState() => _ContinueWatchingScreenState();
}

class _ContinueWatchingScreenState extends State<ContinueWatchingScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = [
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
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // ✅ единый фон
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: const Color(0xFF1A1A1A), // ✅ тот же фон
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
