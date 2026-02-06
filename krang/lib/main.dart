import 'package:flutter/material.dart';

import 'package:krang/pages/User/phone_recovery_page.dart';
import 'package:krang/pages/User/verify_code_page.dart';
import 'package:krang/pages/User/watch_page.dart';

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
import 'pages/admin/movie_admin.dart';
import 'pages/User/phone_verification_page.dart';
import 'pages/admin/edit_movie.dart';
import 'pages/User/reset_password.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Routes Fixed',
      initialRoute: '/login',

      routes: {
        '/onboard1': (context) => OnboardPage(),
        '/onboard2': (context) => OnboardPageSecond(),
        '/registration': (context) => RegisterPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        // '/collections': (context) => CollectionsScreen(),
        '/settings': (context) => SettingsPage(),
        '/support': (context) => SupportScreen(),
        '/continue_watching': (context) => ContinueWatchingScreen(),
        '/my_movies': (context) => MyMoviesPage(),
        '/profile': (context) => ProfilePage(),
        '/admin_home': (context) => const HomePageAdmin(),
        '/phone_verification': (context) => PhoneVerificationPage(),
        '/phone_recovery': (context) => const PhoneRecoveryPage(),
        '/verify_code': (context) => const VerifyCodePage(),
        '/reset_password': (context) => const ResetPasswordPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/edit') {
          final args = settings.arguments as Map<String, dynamic>?;
          final movieId = args?['movieId'] ?? 0;
          return MaterialPageRoute(
            builder: (context) => EditMovieScreen(movieId: movieId),
          );
        }

        if (settings.name == '/movie_details') {
          final args = settings.arguments as Map<String, dynamic>?;
          final movieId = args?['movieId'] ?? 0;
          return MaterialPageRoute(
            builder: (context) => MovieDetailPage(movieId: movieId),
          );
        }
        if (settings.name == '/watch') {
          final args = settings.arguments as Map<String, dynamic>?;
          final movieId = args?['movieId'] ?? 0;
          final title = args?['title'] ?? 'Unknown';
          final videoUrl = args?['videoUrl'];
          return MaterialPageRoute(
            builder: (context) =>
                WatchPage(movieId: movieId, title: title, videoUrl: videoUrl),
          );
        }

        return null;
      },
    );
  }
}
