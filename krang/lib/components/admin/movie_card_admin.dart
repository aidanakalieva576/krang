import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../pages/admin/home_page_admin.dart';



class MovieCardAdmin extends StatefulWidget {
  final ContentItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;
  final VoidCallback onHide;// ✅

  const MovieCardAdmin({
    super.key,
    required this.item,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onHide,
  });


  @override
  State<MovieCardAdmin> createState() => _MovieCardAdminState();
}

class _MovieCardAdminState extends State<MovieCardAdmin> {


  @override
  void initState() {
    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    final isHidden = widget.item.isHidden;

    return Opacity(
      opacity: isHidden ? 0.45 : 1.0,
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
                  widget.item.thumbnailUrl.isNotEmpty   // ✅ исправлено
                      ? widget.item.thumbnailUrl
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

                  Row(
                    children: [
                      _buildIconButton(
                        iconPath: isHidden
                            ? 'assets/icons_admin/unhide.png'
                            : 'assets/icons_admin/hide.png',
                        onTap: widget.onHide, // ✅ вызывает _toggleHidden в HomePageAdmin
                      ),
                      const SizedBox(width: 20),

                      IgnorePointer(
                        ignoring: isHidden,
                        child: _buildIconButton(
                          iconPath: 'assets/icons_admin/edit.png',
                          onTap: widget.onEdit,
                        ),
                      ),
                      const SizedBox(width: 20),

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
