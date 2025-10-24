import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search movies, series, actors...",
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          icon: ImageIcon(
            AssetImage('assets/icons_user/Search.png'),
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
