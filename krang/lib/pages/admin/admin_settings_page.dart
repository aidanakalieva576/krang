import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  String? adminName;
  String? adminEmail;
  bool loading = true;
  String? errorText;

  @override
  void initState() {
    super.initState();
    loadAdminProfile();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _deleteAccount() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Account deleted')));
  }

  Future<void> loadAdminProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        setState(() {
          loading = false;
          errorText = "No token found";
        });
        return;
      }

      final res = await http.get(
        Uri.parse('http://172.20.10.4:8080/api/admin/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // debug
      // ignore: avoid_print
      print('📡 GET /api/admin/me -> ${res.statusCode}');
      // ignore: avoid_print
      print('Body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        setState(() {
          adminName = (data['username'] ?? '').toString();
          adminEmail = (data['email'] ?? '').toString();
          loading = false;
          errorText = null;
        });
      } else {
        setState(() {
          loading = false;
          errorText = "Failed: ${res.statusCode} ${res.body}";
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        errorText = e.toString();
      });
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
              child: RefreshIndicator(
                onRefresh: loadAdminProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          children: [
                            const CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 70,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              adminName?.isNotEmpty == true
                                  ? adminName!
                                  : 'Admin',
                              style: const TextStyle(
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
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      if (loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),

                      if (errorText != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF121212),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            errorText!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      if (!loading && errorText == null) ...[
                        SettingsInfoItem(
                          title: 'Email:',
                          value: (adminEmail?.isNotEmpty == true)
                              ? adminEmail!
                              : '-',
                        ),
                        const SizedBox(height: 18),

                        // если телефона/пароля нет в API — оставь заглушки
                        const SettingsInfoItem(
                          title: 'Phone number:',
                          value: '-',
                        ),
                        const SizedBox(height: 18),

                        const SettingsInfoItem(
                          title: 'Password:',
                          value: '********',
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
                    ],
                  ),
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
