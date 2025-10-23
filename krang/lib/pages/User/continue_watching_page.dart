import 'package:flutter/material.dart';
import '../../components/continue_watching.dart';
import '../../components/navbar.dart';

class ContinueWatchingScreen extends StatelessWidget {
  const ContinueWatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Указываем тип данных явно — Map<String, dynamic>
    final List<Map<String, dynamic>> items = [
      {
        'title': 'K-pop Demon hunters',
        'image': 'assets/icons_user/kpop_demon_hunters.png',
        'progress': 0.8,
      },
      {
        'title': 'The lovely bones',
        'image': 'assets/icons_user/the_lovely_bones.png',
        'progress': 0.6,
      },
      {
        'title': 'The Orange is the new Black',
        'image': 'assets/icons_user/oitnb.png',
        'progress': 0.3,
      },
      {
        'title': 'The Bojack Horseman',
        'image': 'assets/icons_user/the_lovely_bones.png',
        'progress': 0.5,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Continue watching'),
      ),
      body: ListView.builder(
        itemCount: items.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ContinueWatchingItem(
              title: item['title'] as String,
              imagePath: item['image'] as String,
              progress: item['progress'] as double,
            ),
          );
        },
      ),
      bottomNavigationBar: const SizedBox(
        height: 70,
        child: CustomBottomNavBar(),
      ),
    );
  }
}
