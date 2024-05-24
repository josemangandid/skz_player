import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatelessWidget {
  const VideoWidget({
    super.key,
    required this.controller,
    required this.onTap,
    required this.onDoubleTap,
  });

  final VideoPlayerController? controller;
  final Function() onTap;
  final Function() onDoubleTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: ClipRect(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: controller!.value.aspectRatio,
              child: VideoPlayer(controller!),
            ),
          ),
        ),
      ),
    );
  }
}