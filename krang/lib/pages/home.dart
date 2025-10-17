// import 'package:flutter/material.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     int selectedIndex = 0;
//
//     void _onItemTapped(int index) {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//
//     Widget buildCarousel(List<String> images){
//       return SizedBox(
//         height: 180,
//         child: ListView.separated(
//           scrollDirection: Axis.horizontal,
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           itemCount: images.length,
//           separatorBuilder: (_, __) => SizedBox(width: 12),
//           itemBuilder: (context, index) {
//             return ClipRRect(
//               borderRadius: BorderRadius.circular(8),
//               child: Image.network(
//                 images[index],
//                 width: 120,
//                 fit: BoxFit.cover,
//               ),
//             )
//           }
//         ),
//       )
//     }
//     return const Placeholder();
//   }
// }
