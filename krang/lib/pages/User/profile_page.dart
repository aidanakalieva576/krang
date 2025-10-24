import 'package:flutter/material.dart';
import 'package:krang/components/navbar.dart';
import '../../components/profile_header.dart';
import '../../components/profile_menu_item.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CustomBottomNavBar(),
      body: SafeArea(
        child: Column(
          children: [
            const ProfileHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ProfileMenuItem(
                    title: 'Collections',
                    onTap: () {
                      Navigator.pushNamed(context, '/collections');
                    },
                  ),
                  const SizedBox(height: 4),
                  ProfileMenuItem(
                    title: 'Settings',
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  const SizedBox(height: 4),
                  ProfileMenuItem(
                    title: 'Support',
                    onTap: () {
                      Navigator.pushNamed(context, '/support');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
