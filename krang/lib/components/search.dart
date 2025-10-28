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
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF343641),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const TextField(
        textAlignVertical: TextAlignVertical.center, // ✅ центрирует текст
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          isCollapsed: true, // ✅ убирает лишние внутренние отступы
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          hintText: "Search movies, series, actors...",
          hintStyle: TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 10, right: 6),
            child: ImageIcon(
              AssetImage('assets/icons_user/Search.png'),
              color: Colors.white,
              size: 18,
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 32),
        ),
      ),
    );
  }
}
