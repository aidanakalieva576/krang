import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ Логотип KRANG
          Image.asset(
            'assets/icons_user/logo.png',
            height: 42,
          ),

          // ✅ Круглая иконка пользователя (в точности как на фото)
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFF2D2C2C),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 22, // идеально по центру круга
            ),
          ),
        ],
      ),
    );
  }
}
