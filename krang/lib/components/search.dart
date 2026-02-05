import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const Search({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF343641),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: const InputDecoration(
          isCollapsed: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          hintText: "Search movies, series, actors...",
          hintStyle: TextStyle(
            color: Color(0xFF52566C), // ← твой цвет
            fontSize: 13,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white,
            size: 18,
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 40),
        ),
      ),
    );
  }
}
