import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import '../../components/setting_action_item.dart';
import '../../components/setting_header.dart';
import '../../components/setting_info_item.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isLoading = true;
  bool isEditing = false;
  Map<String, dynamic>? userData;
  String? token;
  String? newAvatarPath;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final avatarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAndFetchProfile();
  }

  Future<void> _loadAndFetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('jwt_token');

    if (token == null || token!.isEmpty) {
      if (mounted)
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      return;
    }

    await _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userData = data;
          usernameController.text = data['username'] ?? '';
          emailController.text = data['email'] ?? '';
          avatarController.text = data['avatar'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Ошибка загрузки профиля: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8080/api/users/edit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'avatarUrl': avatarController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', body['token']);
          token = body['token']; // обновляем токен в памяти
        }

        _showToast('Profile updated successfully', isError: false);
        setState(() => isEditing = false);
        _fetchProfile();
      }
    } catch (e) {
      _showToast('Error: $e', isError: true);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted)
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  void _showToast(String message, {bool isError = false}) {
    toastification.show(
      context: context,
      type: isError ? ToastificationType.error : ToastificationType.success,
      style: ToastificationStyle.flat,
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(
        message,
        style: const TextStyle(
          color: Color.fromARGB(255, 26, 24, 55),
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              isEditing ? Icons.check : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              if (isEditing) {
                _updateProfile();
              } else {
                setState(() => isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SettingsHeader(
                        username: usernameController.text,
                        avatarUrl: avatarController.text,
                        isEditing: isEditing,
                        onAvatarChanged: (path) {
                          setState(() => newAvatarPath = path);
                        },
                      ),
                      const SizedBox(height: 16),

                      // username
                      isEditing
                          ? TextField(
                              controller: usernameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputStyle('Username'),
                            )
                          : SettingsInfoItem(
                              title: 'Username',
                              value: userData?['username'] ?? '',
                            ),

                      const SizedBox(height: 12),

                      // email
                      isEditing
                          ? TextField(
                              controller: emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputStyle('Email'),
                            )
                          : SettingsInfoItem(
                              title: 'Email',
                              value: userData?['email'] ?? '',
                            ),

                      const SizedBox(height: 40),

                      SettingsActionItem(
                        title: 'Log out',
                        color: Colors.white70,
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF262C57)),
      ),
    );
  }
}
