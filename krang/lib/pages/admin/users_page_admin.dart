import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:krang/components/search.dart';
import 'package:krang/components/navbar_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class UsersPageAdmin extends StatefulWidget {
  const UsersPageAdmin({super.key});

  @override
  State<UsersPageAdmin> createState() => _UsersPageAdminState();
}

class _UsersPageAdminState extends State<UsersPageAdmin> {
  List<dynamic> users = [];
  bool isLoading = true;
  String _searchQuery = "";

  final List<String> sampleFeedbacks = [
    "Perhaps there is no such person who does not know about the online cinema \"Krang\". Everything is fine with me.",
    "Great app, very convenient UI.",
    "Customer support answered quickly.",
    "Love the catalog.",
    "The app is fast and responsive.",
    "Sometimes recommendations are a bit off.",
    "I like the dark mode.",
  ];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse("http://172.20.10.4:8080/api/admin/users"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          users = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Ошибка запроса: $e");
      setState(() => isLoading = false);
    }
  }

  List<dynamic> get filteredUsers {
    if (_searchQuery.isEmpty) return users;

    return users.where((u) {
      final name = (u["username"] ?? "").toString().toLowerCase();
      final email = (u["email"] ?? "").toString().toLowerCase();
      return name.contains(_searchQuery) || email.contains(_searchQuery);
    }).toList();
  }

  String getRandomFeedback() {
    final random = Random();
    return sampleFeedbacks[random.nextInt(sampleFeedbacks.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Search(
                onChanged: (text) {
                  setState(() {
                    _searchQuery = text.toLowerCase();
                  });
                },
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
                : filteredUsers.isEmpty
                ? const Center(
              child: Text(
                "No users found",
                style: TextStyle(color: Colors.white70),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100, top: 10),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                final bool isActive = user["is_active"] == true;

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0x80414553)
                        : const Color(0x402D2F3E),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 74,
                        height: 74,
                        decoration: const BoxDecoration(
                          color: Color(0xFF414553),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: user["avatar_url"] != null
                            ? ClipOval(
                          child: Image.network(
                            user["avatar_url"],
                            width: 74,
                            height: 74,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Image.asset(
                                  'assets/icons_admin/user.png',
                                  width: 46,
                                  height: 46,
                                ),
                          ),
                        )
                            : Image.asset(
                          'assets/icons_admin/user.png',
                          width: 46,
                          height: 46,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              user["username"] ?? "Unknown",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              user["email"] ?? "no email",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              getRandomFeedback(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const NavbarAdmin(selectedIndex: 1),
        ],
      ),
    );
  }
}
