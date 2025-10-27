import 'package:flutter/material.dart';
import '../components/movies.dart';
import '../components/categoriesComp.dart';
// убрал Search() изнутри — он уже есть на странице выше

class Category extends StatelessWidget {
  const Category({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(                    // <-- было ListView, стало Column
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          // Search(),  // убрал — появился на верхнем уровне CategoriesPage
          SizedBox(height: 0), // можно убрать или оставить для отступа
          CategorySection(),
          SizedBox(height: 20),
          MovieSection(title: "Horror"),
          MovieSection(title: "Scifi"),
          MovieSection(title: "Action"),
          MovieSection(title: "Comedy"),
          MovieSection(title: "Drama"),
        ],
      ),
    );
  }
}
