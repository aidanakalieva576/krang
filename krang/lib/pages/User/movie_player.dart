import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class MoviePlayer extends StatefulWidget {
  const MoviePlayer({super.key});

  @override
  State<MoviePlayer> createState() => _MoviePlayerState();
}

class _MoviePlayerState extends State<MoviePlayer> {
  late VideoPlayerController _controller;
  bool _islandscape = false;


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
