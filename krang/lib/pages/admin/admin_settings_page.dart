import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/setting_info_item.dart';
import '../../components/setting_action_item.dart';
import '../../components/navbar_admin.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  int _selectedIndex = 3;

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _deleteAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100, top: 8),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // всё выровнено слева
                  children: [
                    // 🔹 Заголовок по центру
                    const Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 🔹 Аватар и имя
                    Center(
                      child: Column(
                        children: const [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white, size: 70),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Alexis',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Change profile nickname',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 🔹 Информация (всё прижато к левому краю)
                    const SettingsInfoItem(
                      title: 'Phone number:',
                      value: '+7 777 374 3434',
                    ),
                    const SizedBox(height: 18),
                    const SettingsInfoItem(
                      title: 'Email:',
                      value: 'Alexis@gmail.com',
                    ),
                    const SizedBox(height: 18),
                    const SettingsInfoItem(
                      title: 'Password:',
                      value: 'Shre******09',
                    ),

                    const SizedBox(height: 28),

                    // 🔹 Кнопка Log out
                    SettingsActionItem(
                      title: 'Log out',
                      color: Colors.white70,
                      onTap: _logout,
                    ),

                    const SizedBox(height: 10),

                    // 🔹 Кнопка Delete account
                    SettingsActionItem(
                      title: 'Delete account',
                      color: Colors.white70,
                      onTap: _deleteAccount,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 Навбар внизу
          Align(
            alignment: Alignment.bottomCenter,
            child: NavbarAdmin(selectedIndex: _selectedIndex),
          ),
        ],
      ),
    );
  }
}
