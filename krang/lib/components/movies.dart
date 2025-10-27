import 'package:flutter/material.dart';

class MovieSection extends StatelessWidget {
  final String title;
  const MovieSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final Map<String, List<String>> postersByCategory = {
      'Popular Right Now': [
        'assets/icons_user/barbie.png',
        'assets/icons_user/the_last_of_us.png',
        'assets/icons_user/heads_of_state.png',
      ],
      'Watching right now': [
        'assets/icons_user/chainsawman.png',
        'assets/icons_user/ifrit.png',
        'assets/icons_user/the_smashing_machine.png',
      ],
      'New': [
        'assets/icons_user/the_fast_and_the_furious.png',
        'assets/icons_user/mortal_combat.png',
        'assets/icons_user/barbie.png',
      ],
      'Coming soon': [
        'assets/icons_user/ifrit.png',
        'assets/icons_user/heads_of_state.png',
        'assets/icons_user/the_last_of_us.png',
      ],
      'Horror': [
        'assets/icons_user/chainsawman.png',
        'assets/icons_user/ifrit.png',
      ],
      'Scifi': [
        'assets/icons_user/the_guardians_of_the_galaxy.png',
        'assets/icons_user/the_smashing_machine.png',
      ],
      'Action': [
        'assets/icons_user/the_fast_and_the_furious.png',
        'assets/icons_user/heads_of_state.png',
      ],
      'Comedy': [
        'assets/icons_user/barbie.png',
        'assets/icons_user/the_last_of_us.png',
      ],
      'Drama': [
        'assets/icons_user/the_smashing_machine.png',
        'assets/icons_user/mortal_combat.png',
      ],
    };

    // Берём список по названию категории
    final posterPaths = postersByCategory[title] ?? [];

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
        if (posterPaths.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'No movies available',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
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
