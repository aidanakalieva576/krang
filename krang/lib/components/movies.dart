import 'package:flutter/material.dart';

class MovieSection extends StatelessWidget {
  final String title;
  const MovieSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final List<String> posterPaths = [
      'assets/icons_user/barbie.png',
      'assets/icons_user/chainsawman.png',
      'assets/icons_user/heads_of_state.png',
      'assets/icons_user/ifrit.png',
      'assets/icons_user/the_fast_and_the_furious.png',
      'assets/posters/inception.jpg',
      'assets/icons_user/the_smashing_machine.png',
      'assets/icons_user/the_last_pf_us.png'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: posterPaths.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/movie_details');
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    posterPaths[index],
                    width: 130,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
