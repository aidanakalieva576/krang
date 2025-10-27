import 'package:flutter/material.dart';
import 'package:krang/components/navbar.dart';
import '../../components/setting_action_item.dart';
import '../../components/setting_header.dart';
import '../../components/setting_info_item.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 3; // активная вкладка (профиль)

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // можно добавить навигацию при необходимости
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // Контент
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24,   // 🔹 больше отступ от левого края
                right: 24,  // 🔹 больше отступ от правого края
                bottom: 100,
                top: 8,     // 🔹 немного пространства сверху
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SettingsHeader(),
                    const SizedBox(height: 8),
                    const SettingsInfoItem(
                      title: 'Phone number',
                      value: '+777 374 3434',
                    ),
                    const SettingsInfoItem(
                      title: 'Email',
                      value: 'Alexis@gmail.com',
                    ),
                    const SettingsInfoItem(
                      title: 'Password',
                      value: 'Shre******09',
                    ),
                    const SizedBox(height: 28),
                    SettingsActionItem(
                      title: 'Log out',
                      color: Colors.white70,
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),
                    SettingsActionItem(
                      title: 'Delete account',
                      color: Colors.white70,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ Навбар поверх контента
        ],
      ),
    );
  }
}
