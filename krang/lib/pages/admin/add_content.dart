import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddScheduleModalPage extends StatefulWidget {
  final int movieId;
  final bool isSeries;
  final int seasonNumber;

  const AddScheduleModalPage({
    super.key,
    required this.movieId,
    required this.isSeries,
    this.seasonNumber = 1,
  });

  @override
  State<AddScheduleModalPage> createState() => _AddScheduleModalPageState();
}

class _AddScheduleModalPageState extends State<AddScheduleModalPage> {
  File? _videoFile;
  bool _isUploading = false;

  Future<void> _pickVideo() async {
    if (_isUploading) return;

    final res = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (res == null || res.files.isEmpty) return;

    final path = res.files.single.path;
    if (path == null) return;

    setState(() => _videoFile = File(path));

    await _uploadVideo(); // сразу отправляем
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null) return;

    setState(() => _isUploading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) throw Exception('No token');

      final uri = Uri.parse(
        'http://172.20.10.4:8080/api/admin/movies/${widget.movieId}/videos',
      );

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      // важно: videos
      request.files.add(
        await http.MultipartFile.fromPath('videos', _videoFile!.path),
      );

      request.fields['seasonNumber'] = widget.seasonNumber.toString();

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (!mounted) return;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Episode uploaded!')));

        // ✅ закрываем и говорим EditMovieScreen "успешно"
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error ${response.statusCode}: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFB9B9B9);
    const panel = Color(0xFF0E0F10);
    const textGrey = Color(0xFFE9E9E9);
    const divider = Color(0xFFBDBDBD);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: Container(
            width: 300,
            height: 560,
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: Offset(0, 10),
                  color: Colors.black45,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickVideo,
                    child: Container(
                      height: 210,
                      decoration: BoxDecoration(
                        color: const Color(0xFF777777),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 18,
                            offset: Offset(0, 6),
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _videoFile == null
                            ? Icon(
                                Icons.ios_share_rounded,
                                size: 54,
                                color: Colors.black.withOpacity(0.65),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.video_file,
                                    size: 44,
                                    color: Colors.black.withOpacity(0.65),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Видео выбрано',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.65),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Name:',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(height: 1, color: divider.withOpacity(0.8)),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoundActionButton(
                        diameter: 42,
                        fill: const Color(0xFF2E6D4B),
                        icon: _isUploading
                            ? Icons.hourglass_top
                            : Icons.check_rounded,
                        // ✅ вручную сохранять больше не нужно
                        onTap: null,
                      ),
                      const SizedBox(width: 18),
                      _RoundActionButton(
                        diameter: 42,
                        fill: const Color(0xFF7A2E2E),
                        icon: Icons.close_rounded,
                        onTap: _isUploading
                            ? null
                            : () => Navigator.of(context).pop(false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  final double diameter;
  final Color fill;
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundActionButton({
    required this.diameter,
    required this.fill,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: diameter / 2,
      child: Opacity(
        opacity: onTap == null ? 0.55 : 1.0,
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                blurRadius: 14,
                offset: Offset(0, 6),
                color: Colors.black26,
              ),
            ],
          ),
          child: Center(child: Icon(icon, size: 22, color: Colors.white)),
        ),
      ),
    );
  }
}
