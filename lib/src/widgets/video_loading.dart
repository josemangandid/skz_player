import 'package:flutter/material.dart';

class VideoLoading extends StatelessWidget {
  const VideoLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xffff9d00)),
            ),
          ],
        ),
      ),
    );
  }
}
