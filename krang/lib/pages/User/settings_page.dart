import 'package:flutter/material.dart';
import 'package:krang/components/navbar.dart';
import '../../components/setting_action_item.dart';
import '../../components/setting_header.dart';
import '../../components/setting_info_item.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const CustomBottomNavBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SettingsHeader(),
                const SettingsInfoItem(
                  title: 'Phone number',
                  value: '+777 374 3434',
                ),
                const SettingsInfoItem(
                  title: 'Email',
                  value: 'Alexis@gmail.com',
                ),
                const SettingsInfoItem(
                  title: 'Password',
                  value: 'Shre******09',
                ),
                const SizedBox(height: 24),
                SettingsActionItem(
                  title: 'Log out',
                  icon: Icons.logout,
                  color: Colors.white70,
                  onTap: () {},
                ),
                SettingsActionItem(
                  title: 'Delete account',
                  icon: Icons.delete,
                  color: Colors.redAccent,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
