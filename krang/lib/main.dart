import 'package:flutter/material.dart';
import 'pages/registration.dart';
import 'pages/login.dart';


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
        '/registration': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
      }
    );
  }
}
