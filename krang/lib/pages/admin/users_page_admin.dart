import 'package:flutter/material.dart';
import 'package:krang/components/search.dart';
import 'package:krang/components/navbar_admin.dart';

class UsersPageAdmin extends StatefulWidget {
  const UsersPageAdmin({super.key});

  @override
  State<UsersPageAdmin> createState() => _UsersPageAdminState();
}

class _UsersPageAdminState extends State<UsersPageAdmin> {
  final List<Map<String, String>> users = [
    {"name": "Katie Smolin", "age": "17", "email": "katie@example.com"},
    {"name": "Emily Carter", "age": "22", "email": "emily@example.com"},
    {"name": "Daniel Ross", "age": "19", "email": "daniel@example.com"},
    {"name": "Alex More", "age": "25", "email": "alex@example.com"},
    {"name": "Alex Moore", "age": "25", "email": "alex@example.com"},
    {"name": "Ale Moore", "age": "25", "email": "alex@example.com"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          // --- Основной контент, который пролистывается ---
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 80, bottom: 90),
              child: Column(
                children: users.map((user) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0x80414553),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 74,
                              height: 74,
                              decoration: const BoxDecoration(
                                color: Color(0xFF414553),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/icons_admin/user.png',
                                width: 46,
                                height: 46,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${user["name"]}, ${user["age"]} y.o.",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    user["email"]!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {},
                            child: Image.asset(
                              'assets/icons_admin/delete_user.png',
                              height: 28,
                              width: 28,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // --- Поисковая строка поверх контента ---
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(padding: EdgeInsets.all(16), child: Search()),
            ),
          ),

          // --- Навбар поверх контента ---
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: NavbarAdmin(selectedIndex: 1),
          ),
        ],
      ),
    );
  }
}
