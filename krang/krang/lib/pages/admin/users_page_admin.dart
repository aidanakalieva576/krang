import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:krang/components/search.dart';
import 'package:krang/components/navbar_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsersPageAdmin extends StatefulWidget {
  const UsersPageAdmin({super.key});

  @override
  State<UsersPageAdmin> createState() => _UsersPageAdminState();
}

class _UsersPageAdminState extends State<UsersPageAdmin> {
  List<dynamic> users = [];
  bool isLoading = true;

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
        fetchUsers(); // обновляем список
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("❌ Ошибка удаления: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // 🔍 Поиск
          const SafeArea(
            child: Padding(padding: EdgeInsets.all(16), child: Search()),
          ),

          // 📋 Список пользователей
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
                              : const Color(
                                  0x402D2F3E,
                                ), // темнее если неактивен
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 0,
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

          // 📱 Фиксированный навбар
          const NavbarAdmin(selectedIndex: 1),
        ],
      ),
    );
  }
}
