import 'package:flutter/material.dart';

// импорт всех нужных страниц
import 'pages/registration.dart';
import 'pages/login.dart';
import 'pages/onboarding.dart';
import 'pages/onboarding2.dart';
import 'pages/home.dart';              // ✅ добавь, если есть HomePage
import 'pages/admin/home_page_admin.dart'; // ✅ путь к HomePageAdmin

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Routes False',
      initialRoute: '/',
      routes: {
        '/': (context) => OnboardPage(),
        '/onboard2': (context) => OnboardPageSecond(),
        '/registration': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/admin_home': (context) => const HomePageAdmin(), // ✅ маршрут для админа
      },
    );
  }
}
