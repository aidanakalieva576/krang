import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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

class _WatchPageState extends State<WatchPage> {
  VideoPlayerController? _controller;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    initVideo();
  }

  Future<void> initVideo() async {
    try {
      final url = (widget.videoUrl != null && widget.videoUrl!.isNotEmpty)
          ? widget.videoUrl!
          : 'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4'; // заглушка

      _controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize()
            .then((_) {
              if (!mounted) return;
              setState(() => isLoading = false);
              _controller!.play();
            })
            .catchError((e) {
              print('❌ Ошибка инициализации видео: $e');
              if (mounted) {
                setState(() {
                  isLoading = false;
                  hasError = true;
                });
              }
            });
    } catch (e) {
      print('❌ Ошибка загрузки видео: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            else if (_controller != null && _controller!.value.isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              const Center(
                child: Text(
                  '❌ Ошибка воспроизведения видео.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),

            // Кнопка "назад" + заголовок
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
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

            // Кнопка Play / Pause
            if (!isLoading &&
                !hasError &&
                _controller != null &&
                _controller!.value.isInitialized)
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller!.value.isPlaying
                          ? _controller!.pause()
                          : _controller!.play();
                    });
                  },
                  child: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white.withOpacity(0.8),
                    size: 80,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
