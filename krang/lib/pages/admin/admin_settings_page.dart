import 'package:flutter/material.dart';
import 'package:krang/components/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/setting_action_item.dart';
import '../../components/setting_header.dart';
import '../../components/setting_info_item.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<AdminSettingsPage> {
  int _selectedIndex = 3; // активная вкладка (профиль)

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    // 🔹 Очистим все сохранённые данные
    await prefs.clear();

    // 🔹 Переходим на логин и очищаем стек навигации
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 100,
                top: 8,
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

                    // 🔥 Кнопка Log out
                    SettingsActionItem(
                      title: 'Log out',
                      color: Colors.white70,
                      onTap: _logout,
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
        ],
      ),
    );
  }
}
