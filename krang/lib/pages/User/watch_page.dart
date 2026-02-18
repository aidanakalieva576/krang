import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class WatchPage extends StatefulWidget {
  final int movieId;
  final String title;
  final String? videoUrl;

  const WatchPage({
    super.key,
    required this.movieId,
    required this.title,
    this.videoUrl,
  });

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> with WidgetsBindingObserver {
  static const String _baseUrl = 'http://localhost:8080';

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool isLoading = true;
  bool hasError = false;

  Timer? _progressTimer;
  int _lastSentSec = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    try {
      final url = (widget.videoUrl != null && widget.videoUrl!.isNotEmpty)
          ? widget.videoUrl!
          : 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

      debugPrint('✅ OPEN WATCH PAGE url=$url movieId=${widget.movieId}');

      // 1) Инициализация видео
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();

      // 2) Получаем сохранённый прогресс
      final startSec = await _getProgressSec(widget.movieId);
      debugPrint('⏩ progress from backend = $startSec sec');

      // 3) Ставим на нужную позицию (если > 0)
      if (startSec > 0) {
        await _videoController!.seekTo(Duration(seconds: startSec));
      }

      // 4) Chewie
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        showControls: true,
        allowFullScreen: true,
        allowMuting: true,
        // allowScrubbing в твоей версии chewie НЕТ — поэтому не ставим
      );

      // 5) Раз в 3 сек отправляем прогресс (только если меняется)
      _progressTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
        await _sendProgressIfNeeded();
      });

      if (!mounted) return;
      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('❌ Watch init error: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  // когда приложение сворачивают — тоже сохраним прогресс
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _sendProgressIfNeeded(force: true);
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<int> _getProgressSec(int movieId) async {
    final token = await _getToken();
    if (token == null) return 0;

    final url = Uri.parse('$_baseUrl/api/user/watch-progress/$movieId');

    try {
      final res = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      debugPrint('🟩 GET PROGRESS status=${res.statusCode} body=${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final sec = (data['current_time_sec'] ?? 0);
        if (sec is int) return sec;
        if (sec is num) return sec.toInt();
      }
    } catch (e) {
      debugPrint('❌ GET PROGRESS error: $e');
    }

    return 0;
  }

  Future<void> _sendProgressIfNeeded({bool force = false}) async {
    final vc = _videoController;
    if (vc == null) return;
    if (!vc.value.isInitialized) return;

    final token = await _getToken();
    if (token == null) return;

    final currentSec = vc.value.position.inSeconds;

    // не спамим одинаковыми значениями
    if (!force && currentSec == _lastSentSec) return;
    _lastSentSec = currentSec;

    final url = Uri.parse('$_baseUrl/api/user/watch-progress');

    try {
      final res = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'movie_id': widget.movieId,
          'episode_id': null,
          'current_time_sec': currentSec,
        }),
      );

      debugPrint('🟦 SAVE PROGRESS status=${res.statusCode} body=${res.body}');
    } catch (e) {
      debugPrint('❌ SAVE PROGRESS error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // на выходе — обязательно сохраним прогресс
    _sendProgressIfNeeded(force: true);

    _progressTimer?.cancel();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _sendProgressIfNeeded(force: true);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else if (hasError)
                const Center(
                  child: Text(
                    '⚠️ Видео не удалось загрузить.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              else if (_chewieController != null)
                  Center(child: Chewie(controller: _chewieController!))
                else
                  const Center(
                    child: Text(
                      '❌ Ошибка воспроизведения видео.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),

              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () async {
                        await _sendProgressIfNeeded(force: true);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}