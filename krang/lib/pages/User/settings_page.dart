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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Контент
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SettingsHeader(),
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
                    const SizedBox(height: 24),
                    SettingsActionItem(
                      title: 'Log out',
                      color: Colors.white70, // ✅ добавили цвет
                      onTap: () {},
                    ),
                    SettingsActionItem(
                      title: 'Delete account',
                      color: Colors.redAccent, // ✅ добавили цвет
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
