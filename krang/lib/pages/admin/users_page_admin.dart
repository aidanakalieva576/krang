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

  // Список случайных фидбеков
  final List<String> sampleFeedbacks = [
    "Perhaps there is no such person who does not know about the online cinema \"Krang\". Everything is fine with me. I've even gotten used to the monthly subscription fee.",
    "Great app, very convenient UI. I wish there were more filtering options for recommendations and better subtitles support.",
    "Customer support answered quickly. Found a small bug in the player — it sometimes freezes on skip. Please check.",
    "Love the catalog. Could be nice to have a 'watch later' sync across devices.",
    "Everything works fine for me. The monthly pricing is ok. I'd like to see more anime.",
    "The app is fast and responsive, no lag issues.",
    "Sometimes recommendations are a bit off, but overall good.",
    "I like the dark mode and the clean design.",
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
        print("❌ Нет токена — пользователь не авторизован.");
        setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse("http://localhost:8080/api/admin/users"),
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
        print("⚠️ Ошибка при загрузке пользователей: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Ошибка запроса: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          "Are you sure?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Do you really want to delete this user?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await http.delete(
        Uri.parse("http://localhost:8080/api/admin/delete"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User deleted successfully")),
        );
        fetchUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("❌ Ошибка удаления: $e");
    }
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
          const SafeArea(
            child: Padding(padding: EdgeInsets.all(16), child: Search()),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100, top: 10),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
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
                                  child: user["avatar_url"] != null
                                      ? ClipOval(
                                          child: Image.network(
                                            user["avatar_url"],
                                            width: 74,
                                            height: 74,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) => Image.asset(
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
                                Flexible(
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
                            // Иконка удаления
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => deleteUser(user["email"]),
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
                    },
                  ),
          ),
          const NavbarAdmin(selectedIndex: 1),
        ],
      ),
    );
  }
}
