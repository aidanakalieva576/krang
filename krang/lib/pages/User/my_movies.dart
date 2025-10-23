import 'package:flutter/material.dart';
import 'package:krang/components/navbar.dart';
import '../../components/movies_header.dart';
import '../../components/movie_card.dart';

class MyMoviesPage extends StatelessWidget {
  const MyMoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CustomBottomNavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              MoviesHeader(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Text(
                  'Continue watching',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              MovieCard(
                imagePath: 'assets/icons_user/brooklyn_movie.png',
                title: 'Brooklyn Nine-Nine',
                subtitle: 'Sitcom, 2003',
                seasons: '8 seasons',
              ),
              MovieCard(
                imagePath: 'assets/icons_user/desperate_housewives.png',
                title: 'Desperate Housewives',
                subtitle: 'Drama, 2004',
                seasons: '8 seasons',
              ),
              MovieCard(
                imagePath: 'assets/icons_user/arcane.png',
                title: 'Arcane',
                subtitle: 'Action, 2021',
                seasons: '2 seasons',
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
