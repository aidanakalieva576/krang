import 'package:flutter/material.dart';
import '../../components/movie_poster.dart';
import '../../components/movie_info.dart';
import '../../components/movie_extra_info.dart';
import '../../components/movie_description.dart';

class MovieDetailPage extends StatelessWidget {
  const MovieDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const MoviePoster(imagePath: 'assets/icons_user/ITonya.png'),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const MovieInfo(
                  title: 'I, Tonya',
                  subtitle: '8.5 · Tragicomedy, LuckyChap',
                  duration: '2h',
                  age: '18+',
                  rating: 5,
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF0F2027)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/watch');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Watch',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const MovieDescription(
                  description:
                  'I, Tonya is a 2017 American biographical sports film chronicling the tumultuous life of American figure skater Tonya Harding, focusing on her rise, her abusive upbringing, dysfunctional relationships, and her involvement in the infamous 1994 attack on rival Nancy Kerrigan.',
                ),
                const SizedBox(height: 16),
                const MovieExtraInfo(
                  year: '2023',
                  platform: 'LuckyChap',
                  director: 'Craig Gillespie',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
