import 'package:flutter/material.dart';
import '../../components/navbar.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  int _selectedIndex = 2; // допустим, коллекции — третья вкладка

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // можно добавить переходы, если нужно
  }

  @override
  Widget build(BuildContext context) {
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
                    'Collections',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icons_user/collection.png',
                              height: 100,
                              width: 100,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'A space where all your movies and series are neatly organized by genre, type, and your personal preferences.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ Навбар поверх контента
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
