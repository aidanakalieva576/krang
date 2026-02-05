import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({super.key});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _verifyCode(String phone, String email) async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showSnack('Enter the code from SMS');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('jwt_token');
      // if (token == null) {
      //   _showSnack('Please log in first');
      //   return;
      // }

      final res = await http.post(
        Uri.parse('http://localhost:8080/api/phone/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'code': code}),
      );


      if (res.statusCode == 200) {
        _showSnack('Code verified');

        Navigator.pushReplacementNamed(
          context,
          '/reset_password',
          arguments: {'email': email, 'code': code},
        );
        debugPrint(
          "HEHE Navigating to /reset_password with email='$email' and code='$code'",
        );
      } else {
        final data = jsonDecode(res.body);
        _showSnack(data['error'] ?? 'Invalid code');
      }
    } catch (e) {
      _showSnack('Network error');
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
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final phone = (args['phone'] ?? '').toString();
    final email = (args['email'] ?? '').toString();

    debugPrint(
      "VerifyCodePage phone='$phone' email='$email' args=${ModalRoute.of(context)?.settings.arguments}",
    );
    final maskedphone = phone.toString().replaceRange(3, 7, '****');

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Verification'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              'We sent SMS to $maskedphone',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Enter code',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigoAccent),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _verifyCode(phone, email),
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
                      'Verify',
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
