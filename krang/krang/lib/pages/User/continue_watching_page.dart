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
        'title': 'K-pop Demon hunters',
        'image': 'assets/icons_user/kpop_demon_hunters.png',
        'progress': 0.9,
      },
      {
        'title': 'The lovely bones',
        'image': 'assets/icons_user/the_lovely_bones.png',
        'progress': 0.75,
      },
      {
        'title': 'The Orange is the new Black',
        'image': 'assets/icons_user/oitnb.png',
        'progress': 0.25,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: const [
                      BackButton(color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Continue watching',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: items.length,
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNavBar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
