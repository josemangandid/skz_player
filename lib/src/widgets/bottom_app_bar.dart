import 'package:flutter/material.dart';
import 'package:skz_player/src/widgets/progress_bar.dart';
import 'package:skz_player/src/widgets/progress_colors.dart';
import 'package:video_player/video_player.dart';

Color progressBarPlayedColor = Colors.white;
Color progressBarHandleColor = Colors.white;
Color progressBarBufferedColor = Colors.white70;
Color progressBarBackgroundColor = Colors.white60;

class BottomAppBarWidget extends StatelessWidget {
  const BottomAppBarWidget({
    super.key,
    required this.showMenu,
    required this.fullScreen,
    required this.wasLoading,
    required this.controller,
    required this.videoSeek,
    required this.videoDuration,
    this.onToNextVideo,
    this.onDragStart,
    this.onDragEnd,
    this.onTapDown,
  });

  final bool showMenu;
  final bool fullScreen;
  final bool wasLoading;
  final VideoPlayerController controller;
  final String videoSeek;
  final String videoDuration;
  final Function()? onToNextVideo;
  final Function()? onDragStart;
  final Function()? onDragEnd;
  final Function()? onTapDown;

  @override
  Widget build(BuildContext context) {
    return showMenu && !wasLoading
        ? Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          "$videoSeek / $videoDuration",
                          style: TextStyle(
                              fontSize: fullScreen ? 16 : 12,
                              color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      if (onToNextVideo != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 15.0),
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                const Color(0xff303030),
                              ),
                            ),
                            onPressed: onToNextVideo,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Siguiente",
                                  style: TextStyle(
                                    fontSize: fullScreen ? 16 : 12,
                                    color: Colors.white,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: fullScreen ? 20 : 16,
                                ),
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: SizedBox(
                      height: 30,
                      child: ProgressBar(
                        controller,
                        onDragStart: onDragStart,
                        onDragEnd: onDragEnd,
                        onTapDown: onTapDown,
                        colors: ProgressColors(
                          playedColor: progressBarPlayedColor,
                          handleColor: progressBarHandleColor,
                          bufferedColor: progressBarBufferedColor,
                          backgroundColor: progressBarBackgroundColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
