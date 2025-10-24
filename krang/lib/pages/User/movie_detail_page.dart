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
          const MoviePoster(imagePath: 'assets/ITonya.png'),

          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: const Column(
              children: [
                MovieInfo(
                  title: 'I, Tonya',
                  subtitle: '8.5 · Tragicomedy, LuckyChap',
                  duration: '2h',
                  age: '18+',
                  rating: 5,
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: null,//потом переход на просмотр
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.blueGrey),
                      padding: MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 16)),
                      shape: MaterialStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                    child: Text('Watch', style: TextStyle(fontSize: 18)),
                  ),
                ),
                SizedBox(height: 16),
                MovieDescription(
                  description:
                  'I, Tonya is a 2017 American biographical sports film chronicling the tumultuous life of American figure skater Tonya Harding, focusing on her rise, her abusive upbringing, dysfunctional relationships, and her involvement in the infamous 1994 attack on rival Nancy Kerrigan.',
                ),
                SizedBox(height: 16),
                MovieExtraInfo(
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
