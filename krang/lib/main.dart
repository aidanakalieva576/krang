import 'package:flutter/material.dart';

// импорт всех нужных страниц
import 'pages/User/registration.dart';
import 'pages/User/login.dart';
import 'pages/User/onboarding.dart';
import 'pages/User/onboarding2.dart';
import 'pages/User/home.dart';
import 'pages/admin/home_page_admin.dart';
import 'pages/User/collections_page.dart';
import 'pages/User/settings_page.dart';
import 'pages/User/support_page.dart';
import 'pages/User/continue_watching_page.dart';
import 'pages/User/movie_detail_page.dart';
import 'pages/User/my_movies.dart';
import 'pages/User/profile_page.dart';
import 'pages/admin/edit_movie.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Routes False',
      initialRoute: '/login',
      routes: {
        '/onboard1': (context) => OnboardPage(),
        '/onboard2': (context) => OnboardPageSecond(),
        '/registration': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/collections': (context) => CollectionsScreen(),
        '/settings': (context) => SettingsPage(),
        '/support': (context) => SupportScreen(),
        '/continue_watching': (context) => ContinueWatchingScreen(),
        '/movie_details': (context) => MovieDetailPage(),
        '/my_movies': (context) => MyMoviesPage(),
        '/profile': (context) => ProfilePage(),
        '/edit': (context) => EditMovieScreen(),
        '/admin_home': (context) =>
            const HomePageAdmin(), // ✅ маршрут для админ
      },
    );
  }
}
