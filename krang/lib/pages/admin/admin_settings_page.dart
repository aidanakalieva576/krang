import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/setting_action_item.dart';
import '../../components/setting_info_item.dart';
import '../../components/navbar_admin.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  int _selectedIndex = 3; // активная вкладка (настройки)

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    // 🔹 Очистим сохранённые данные
    await prefs.clear();

    // 🔹 Переход на логин с очисткой стека
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
                    // 🔹 Хедер с аватаром и именем
                    Column(
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/icons_user/avatar.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Alexis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Change profile nickname',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

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

                    // 🔥 Log out
                    SettingsActionItem(
                      title: 'Log out',
                      color: Colors.white70,
                      onTap: _logout,
                    ),

                    const SizedBox(height: 10),

                    // 🧨 Delete account
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

          // 🔹 Навбар внизу
          Align(
            alignment: Alignment.bottomCenter,
            child: NavbarAdmin(
              selectedIndex: _selectedIndex,
            ),
          ),
        ],
      ),
    );
  }
}
