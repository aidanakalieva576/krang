import 'package:flutter/material.dart';

class MoviePoster extends StatelessWidget {
  final String imagePath;
  const MoviePoster({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          width: double.infinity,
          child: Image.asset(imagePath,
          fit: BoxFit.cover,
          ),
        ),

        Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.9),
              ]
            )
          ),
        )
      ],
    );
  }
}
