import 'package:flutter/material.dart';
import 'pages/registration.dart';
import 'pages/login.dart';
import 'pages/onboarding.dart';
import 'pages/onboarding2.dart';
import 'pages/home.dart';

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
      routes:{
        '/': (context) => OnboardPage(),
        '/onboard2': (context) => OnboardPageSecond(),
        '/registration': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      }
    );
  }
}
