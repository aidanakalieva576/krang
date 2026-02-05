import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PhoneRecoveryPage extends StatefulWidget {
  const PhoneRecoveryPage({super.key});

  @override
  State<PhoneRecoveryPage> createState() => _PhoneRecoveryPageState();
}

class _PhoneRecoveryPageState extends State<PhoneRecoveryPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _recoverByEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnack('Enter your email address');
      return;
    }

    // Простая проверка формата
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showSnack('Enter the correct email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await http.post(
        Uri.parse('http://172.20.10.4:8080/api/recovery/email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final maskedPhone = data['maskedPhone'] ?? 'number';
        final phone = data['phone'];

        _showSnack('Код отправлен на $maskedPhone');

        // 🔹 переход на экран проверки кода
        Navigator.pushNamed(
          context,
          '/verify_code',
          arguments: {'email': email, 'phone': phone},
        );
        debugPrint(
          "Navigating to /verify_code with email='$email' and phone='$phone', maskedPhone='$maskedPhone'",
        );
      } else {
        final data = jsonDecode(res.body);
        _showSnack(data['error'] ?? 'Could not send the code');
      }
    } catch (e) {
      _showSnack('Ошибка сети');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Mail Recovery'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Text(
              'Enter your email address.\nWe will send the code to the phone number linked to it.',
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Email',
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
            ElevatedButton(
              onPressed: _isLoading ? null : _recoverByEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 80,
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.indigo)
                  : const Text(
                      'Send code',
                      style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
