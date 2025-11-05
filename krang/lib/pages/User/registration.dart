import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _register() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // 🔹 Локальные проверки до запроса
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showToast("Please fill in all fields", isError: true);
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showToast("Please enter a valid email address", isError: true);
      return;
    }
    if (password.length < 6) {
      _showToast("Password must be at least 6 characters", isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse('http://192.168.123.35:8080/api/auth/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      Map<String, dynamic>? data;
      if (response.body.isNotEmpty) {
        try {
          data = jsonDecode(response.body);
        } catch (_) {}
      }

      if (response.statusCode == 201 && data != null) {
        final token = data['token'];

        if (token == null) {
          _showToast("No token returned from server", isError: true);
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);

        usernameController.clear();
        emailController.clear();
        passwordController.clear();

        _showToast("Account created successfully!", isError: false);

        if (mounted) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(context, '/phone_verification');
          });
        }
      } else {
        String errorMsg = data?['error'] ?? 'Registration failed';

        if (errorMsg.toLowerCase().contains('exists')) {
          errorMsg = "This email is already registered";
        } else if (errorMsg.toLowerCase().contains('password')) {
          errorMsg = "Password is too weak";
        }

        _showToast(errorMsg, isError: true);
      }
    } catch (e) {
      _showToast('Connection error. Please try again later.', isError: true);
    } finally {
      setState(() => isLoading = false);
    }
  }

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
      style: ToastificationStyle.flat, // 👈 самый лёгкий и универсальный
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
                'Register',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'username',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(63, 81, 181, 1),
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigoAccent),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: emailController,
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
                controller: passwordController,
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
                  onPressed: isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.indigo)
                      : const Text(
                          'register',
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text(
                  'I have already account',
                  style: TextStyle(
                    color: Colors.grey,
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
