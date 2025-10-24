import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/icons_user/logo.png',
            height: 40,
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[800],
            child: ClipOval(
              child: Image.asset(
                'assets/avatar.png',
                fit: BoxFit.cover,
                width: 36,
                height: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
