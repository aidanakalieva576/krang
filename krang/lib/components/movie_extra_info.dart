import 'package:flutter/material.dart';

class MovieExtraInfo extends StatelessWidget {
  final String year;
  final String platform;
  final String director;
  const MovieExtraInfo({
    super.key,
    required this.year,
    required this.platform,
    required this.director,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _InfoColumn(title: 'Year', value: year),
        _InfoColumn(title: 'Platform', value: platform),
        _InfoColumn(title: 'Director', value: director),
        GestureDetector(
          onTap: () {},
          child: Image.asset(
            'assets/icons_user/favourite.png',
            width: 28,
            height: 28,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;
  const _InfoColumn({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white54)),
        Text(title, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
