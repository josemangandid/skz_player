import 'package:flutter/material.dart';
import 'package:skz_player/src/responses/play_response.dart';
import 'package:skz_player/src/source/video_style.dart';
import 'package:video_player/video_player.dart';

class PlayPauseAndBackForward extends StatelessWidget {
  const PlayPauseAndBackForward({
    super.key,
    required this.controller,
    required this.videoStyle,
    required this.play,
    required this.wasLoading,
    required this.fullScreen,
    required this.showMenu,
  });

  final VideoPlayerController controller;
  final VideoStyle videoStyle;
  final Function() play;
  final bool wasLoading;
  final bool fullScreen;
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    return showMenu && !wasLoading
        ? Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        rewind(controller);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: (fullScreen ? 40 : 20), vertical: 5),
                        child: Icon(
                          Icons.replay_10,
                          color: Colors.white,
                          size: fullScreen ? 50 : 30,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: play as void Function()?,
                    child: Icon(
                      controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: fullScreen ? 55 : 35,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        fastForward(controller: controller);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: (fullScreen ? 40 : 20), vertical: 5),
                        child: Icon(
                          Icons.forward_10,
                          color: Colors.white,
                          size: fullScreen ? 50 : 30,
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
