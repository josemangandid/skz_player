import 'package:cast/cast.dart';
import 'package:flutter/material.dart';
import 'package:skz_player/src/source/video_loading_style.dart';
import 'package:skz_player/src/source/video_style.dart';
import 'package:skz_player/src/widgets/acction_bar.dart';
import 'package:skz_player/src/widgets/bottom_app_bar.dart';
import 'package:skz_player/src/widgets/play_pause_and_back_forward.dart';
import 'package:skz_player/src/widgets/shadow.dart';
import 'package:video_player/video_player.dart';

class ControlsWidget extends StatelessWidget {
  const ControlsWidget({
    super.key,
    required this.fullScreen,
    required this.showMenu,
    required this.toggleControls,
    required this.togglePlay,
    required this.wasLoading,
    required this.toggleFullScreen,
    required this.style,
    required this.controller,
    required this.videoSeek,
    required this.videoDuration,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onTapDown,
    required this.onToNextVideo,
    required this.onTapCastBtn,
    required this.videoStyle,
    this.appCastId,
    this.videoTitle,
  });

  final VideoPlayerController controller;
  final VideoLoadingStyle style;
  final VideoStyle videoStyle;
  final bool fullScreen;
  final bool showMenu;
  final bool wasLoading;
  final Function() toggleControls;
  final Function() togglePlay;
  final Function() toggleFullScreen;
  final Function()? onToNextVideo;
  final Function() onDragStart;
  final Function() onDragEnd;
  final Function() onTapDown;
  final Function() onTapCastBtn;
  final String videoSeek;
  final String videoDuration;
  final String? appCastId;
  final String? videoTitle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ShadowWidget(
          showMenu: showMenu,
          onTap: toggleControls,
          onDoubleTap: togglePlay,
        ),
        wasLoading ? style.loading : Container(),
        ActionBar(
          appCastId: appCastId,
          onTapCastBtn: onTapCastBtn,
          wasLoading: wasLoading,
          showMenu: showMenu,
          fullScreen: fullScreen,
          toggleFullScreen: toggleFullScreen,
        ),
        BottomAppBarWidget(
          showMenu: showMenu,
          fullScreen: fullScreen,
          wasLoading: wasLoading,
          controller: controller,
          videoSeek: videoSeek,
          videoDuration: videoDuration,
          onDragEnd: onDragEnd,
          onDragStart: onDragStart,
          onTapDown: onTapDown,
          onToNextVideo: onToNextVideo,
        ),
        PlayPauseAndBackForward(
          controller: controller,
          videoStyle: videoStyle,
          play: togglePlay,
          wasLoading: wasLoading,
          fullScreen: fullScreen,
          showMenu: showMenu,
        )
      ],
    );
  }
}
