import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingsHeader extends StatefulWidget {
  final String username;
  final String avatarUrl;
  final bool isEditing;
  final Function(String)? onAvatarChanged; // 👈 колбэк при изменении фото

  const SettingsHeader({
    super.key,
    required this.username,
    required this.avatarUrl,
    required this.isEditing,
    this.onAvatarChanged,
  });

  @override
  State<SettingsHeader> createState() => _SettingsHeaderState();
}

class _SettingsHeaderState extends State<SettingsHeader> {
  File? _newImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _newImage = File(picked.path);
      });

      // 👇 передаём путь наружу (в SettingsPage)
      widget.onAvatarChanged?.call(picked.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              // --- Фото пользователя ---
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _newImage != null
                        ? FileImage(_newImage!)
                        : (widget.avatarUrl.isNotEmpty
                              ? NetworkImage(widget.avatarUrl)
                              : const AssetImage(
                                      'assets/icons_user/default_avatar.png',
                                    )
                                    as ImageProvider),
                    fit: BoxFit.cover,
                    colorFilter: widget.isEditing
                        ? ColorFilter.mode(
                            Colors.black.withOpacity(0.4),
                            BlendMode.darken,
                          )
                        : null,
                  ),
                ),
              ),

              // --- Иконка камеры при редактировании ---
              if (widget.isEditing)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
