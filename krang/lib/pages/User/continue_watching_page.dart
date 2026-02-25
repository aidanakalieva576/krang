import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/continue_watching.dart';
import '../../components/navbar.dart';

class ContinueWatchingScreen extends StatefulWidget {
  const ContinueWatchingScreen({super.key});

  @override
  State<ContinueWatchingScreen> createState() => _ContinueWatchingScreenState();
}

class _ContinueWatchingScreenState extends State<ContinueWatchingScreen> {
  int _selectedIndex = -1;

  bool _loading = true;
  bool _error = false;
  List<Map<String, dynamic>> _items = [];

  static const String _baseUrl = 'http://172.20.10.4:8080';

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  void initState() {
    super.initState();
    _fetchContinueWatching();
  }

  Future<void> _fetchContinueWatching() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        setState(() {
          _items = [];
          _loading = false;
        });
        return;
      }

      final res = await http.get(
        Uri.parse('$_baseUrl/api/user/watch-progress/continue-watching'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _items = data.cast<Map<String, dynamic>>();
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    } catch (e) {
      debugPrint('❌ continue watching error: $e');
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: const [
                      BackButton(color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Continue watching',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _loading
                      ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                      : _error
                      ? Center(
                    child: TextButton(
                      onPressed: _fetchContinueWatching,
                      child: const Text(
                        'Ошибка загрузки. Нажми чтобы повторить',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                      : _items.isEmpty
                      ? const Center(
                    child: Text(
                      'Ты пока ничего не смотришь 🙂',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];

                      final movieId = (item['movie_id'] as num).toInt();
                      final title = (item['title'] ?? '') as String;
                      final imageUrl = (item['thumbnail_url'] ?? '') as String;
                      final videoUrl = (item['video_url'] ?? '') as String;

                      final currentSec = (item['current_time_sec'] as num?)?.toInt() ?? 0;
                      final durationSec = (item['duration_seconds'] as num?)?.toInt() ?? 0;

                      final progress = durationSec > 0
                          ? (currentSec / durationSec).clamp(0.0, 1.0)
                          : 0.0;


                      debugPrint(
                        '🎯 CW item movieId=$movieId current=$currentSec duration=$durationSec progress=$progress',
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/watch',
                              arguments: {
                                'movieId': movieId,
                                'title': title,
                                'videoUrl': videoUrl,
                              },
                            ).then((_) => _fetchContinueWatching());
                          },
                          child: ContinueWatchingItem(
                            title: title,
                            imagePath: imageUrl,
                            progress: progress,
                          ),
                        ),

                      );
                    },


                  ),
                ),
              ],
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNavBar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
