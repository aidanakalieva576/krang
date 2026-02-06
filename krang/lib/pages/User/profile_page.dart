import 'package:flutter/material.dart';
import 'package:krang/components/navbar.dart';
import '../../components/profile_header.dart';
import '../../components/profile_menu_item.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3; // вкладка профиля активна

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // можно добавить переходы по вкладкам
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  const ProfileHeader(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // ProfileMenuItem(
                        //   title: 'Collections',
                        //   backgroundColor: const Color(0xFF2D2C2C),
                        //   onTap: () {
                        //     Navigator.pushNamed(context, '/collections');
                        //   },
                        // ),
                        const SizedBox(height: 8),
                        ProfileMenuItem(
                          title: 'Settings',
                          backgroundColor: const Color(0xFF2D2C2C),
                          onTap: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                        const SizedBox(height: 8),
                        ProfileMenuItem(
                          title: 'Support',
                          backgroundColor: const Color(0xFF2D2C2C),
                          onTap: () {
                            Navigator.pushNamed(context, '/support');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
