import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../pages/admin/home_page_admin.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MovieCardAdmin extends StatefulWidget {
  final ContentItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const MovieCardAdmin({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  @override
  State<MovieCardAdmin> createState() => _MovieCardAdminState();
}

class _MovieCardAdminState extends State<MovieCardAdmin> {
  late bool isHidden;

  @override
  void initState() {
    super.initState();
    isHidden = widget.item.is_hidden ?? false;
  }

  /// 🛰️ Обновляем флаг is_hidden в БД
  Future<void> _toggleHidden() async {
    final endpoint = isHidden ? 'unhide' : 'hide';
    final url = Uri.parse(
      'http://10.0.2.2:8080/api/admin/movies/${widget.item.id}/$endpoint',
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token'); // ← сохраняется при логине

      if (token == null) {
        debugPrint('❌ Нет токена авторизации');
        return;
      }

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 👈 обязательно
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          isHidden = !isHidden;
        });
        debugPrint('✅ Фильм ${isHidden ? "скрыт" : "показан"}');
      } else {
        debugPrint('❌ Ошибка при обновлении: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Ошибка при подключении к серверу: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isHidden ? 0.45 : 1.0, // 🔹 затемняем всю карточку
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0x80414553),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🎬 Постер фильма
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ColorFiltered(
                colorFilter: isHidden
                    ? const ColorFilter.mode(Colors.black45, BlendMode.darken)
                    : const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.multiply,
                      ),
                child: Image.network(
                  widget.item.thumbnail_url.isNotEmpty
                      ? widget.item.thumbnail_url
                      : 'https://via.placeholder.com/120x160',
                  width: 90,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 20),

            // 🧾 Название и кнопки
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // 🔘 Кнопки действий
                  Row(
                    children: [
                      // 👁 Кнопка hide/unhide — всегда активна
                      _buildIconButton(
                        iconPath: isHidden
                            ? 'assets/icons_admin/unhide.png'
                            : 'assets/icons_admin/hide.png',
                        onTap: _toggleHidden,
                      ),
                      const SizedBox(width: 20),

                      // ✏️ Редактировать (недоступно если скрыто)
                      IgnorePointer(
                        ignoring: isHidden,
                        child: _buildIconButton(
                          iconPath: 'assets/icons_admin/edit.png',
                          onTap: widget.onEdit,
                        ),
                      ),
                      const SizedBox(width: 20),

                      // 🗑 Удалить (недоступно если скрыто)
                      IgnorePointer(
                        ignoring: isHidden,
                        child: _buildIconButton(
                          iconPath: 'assets/icons_admin/delete_movie.png',
                          onTap: widget.onDelete,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔘 Кнопка с иконкой
  Widget _buildIconButton({
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Image.asset(
          iconPath,
          width: 34,
          height: 34,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
