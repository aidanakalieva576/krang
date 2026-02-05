import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 🔹 Локальные проверки
    if (email.isEmpty || password.isEmpty) {
      _showToast("Please fill in all fields", isError: true);
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showToast("Please enter a valid email address", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('http://172.20.10.4:8080/api/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Login success: $data');
        // Сохраняем токен/роль/почту в SharedPreferences (если есть)
        final role = data['role'] as String?;
        final token = data['token'] as String?;

        final prefs = await SharedPreferences.getInstance();
        if (token != null) await prefs.setString('jwt_token', token);
        if (role != null) await prefs.setString('role', role);
        await prefs.setString('user_email', email);
        debugPrint('Token saved in SharedPreferences');

        _showToast("Login successful!", isError: false);

        // Навигация
        if (mounted) {
          Future.delayed(const Duration(seconds: 1), () {
            if (role == 'ADMIN') {
              Navigator.pushReplacementNamed(context, '/admin_home');
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          });
        }
      } else {
        String message = 'Invalid email or password';
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['error'] != null) {
            message = body['error'].toString();
          }
        } catch (_) {}

        if (message.toLowerCase().contains('user')) {
          message = "User not found";
        } else if (message.toLowerCase().contains('password')) {
          message = "Incorrect password";
        }

        _showToast(message, isError: true);
      }
    } catch (_) {
      _showToast("Connection error. Please try again later.", isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 🔔 Универсальный красивый toast
  void _showToast(String message, {bool isError = false}) {
    final background = isError
        ? Colors.redAccent.withOpacity(0.15)
        : Colors.greenAccent.withOpacity(0.15);

    final border = isError
        ? Colors.redAccent.withOpacity(0.4)
        : Colors.greenAccent.withOpacity(0.4);

    toastification.show(
      context: context,
      type: isError ? ToastificationType.error : ToastificationType.success,
      style: ToastificationStyle.flat,
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.none,
      dragToClose: true,
      backgroundColor: background,
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: border, width: 1.2),
      title: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      boxShadow: [
        BoxShadow(
          color: isError
              ? Colors.redAccent.withOpacity(0.25)
              : Colors.greenAccent.withOpacity(0.25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Log in',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'email',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigo),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigoAccent),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'password',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigo),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigoAccent),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.indigo)
                      : const Text(
                          'Log in',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/registration');
                },
                child: const Text(
                  'I do not have an account',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/phone_recovery');
                },
                child: const Text(
                  'Forgot your account? Recover via phone',
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
