import 'dart:async';

import 'package:cast/cast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skz_player/src/source/video_loading_style.dart';
import 'package:skz_player/src/source/video_style.dart';
import 'package:skz_player/src/utils/utils.dart';
import 'package:skz_player/src/widgets/cast_dialog.dart';
import 'package:skz_player/src/widgets/controls_widget.dart';
import 'package:skz_player/src/widgets/video_widget.dart';

import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SkzPlayer extends StatefulWidget {
  ///Video[source],
  ///```dart
  ///url:"https://example.com/index.m3u8";
  ///```
  final String url;

  final String? videoTitle;

  /// Google Cast Id
  final String? appCastId;

  final VideoStyle? videoStyle;

  /// Video AspectRatio [aspectRatio : 16 / 9 ]
  final double aspectRatio;

  /// Video start at specific time
  final Duration? startAt;

  /// video state fullScreen
  final void Function(bool fullScreenTurnedOn)? onFullScreen;

  /// Video Loading Style
  final VideoLoadingStyle? videoLoadingStyle;

  /// Return current video position
  final Function(int position)? position;

  final Function()? onToNextVideo;

  const SkzPlayer({
    super.key,
    required this.url,
    this.aspectRatio = 16 / 9,
    this.startAt,
    this.appCastId,
    this.onFullScreen,
    this.videoLoadingStyle,
    this.position,
    this.onToNextVideo,
    this.videoStyle,
    this.videoTitle,
  });

  @override
  State<SkzPlayer> createState() => _SkzPlayerState();
}

class _SkzPlayerState extends State<SkzPlayer>
    with SingleTickerProviderStateMixin {
  //Chromecast Controller
  ChromecastController? chromecastController;

  // Animation Controller
  late AnimationController controlBarAnimationController;

  // Video Top Bar Animation
  Animation<double>? controlTopBarAnimation;

  // Video Bottom Bar Animation
  Animation<double>? controlBottomBarAnimation;

  // Video Player Controller
  VideoPlayerController? controller;

  // video full screen
  late VideoLoadingStyle videoLoadingStyle;

  // Video icons style
  late VideoStyle videoStyle;

  // video full screen
  bool fullScreen = false;

  // Video init error default :false
  bool hasInitError = false;

  bool _fullscreen = false;

  //Current ScreenSize
  Size get screenSize => MediaQuery.of(context).size;

  // Current video position
  final _position = 0;

  // menu show
  bool showMenu = false;

  // time for duration
  Timer? showTime;

  // Video Seed to
  String? videoSeek;

  // Video Total Time duration
  String? videoDuration;

  // video seek second by user
  double? videoSeekSecond;

  // video duration second
  double? videoDurationSecond;

  VideoPlayerValue? _latestValue;

  bool _wasLoading = true;

  bool controlsNotVisible = true;

  Timer? _hideTimer;

  OverlayEntry? _overlayEntry;

  int currentPosition = 0;

  CastSessionState? sessionState;

  bool isOpenCastDialog = false;

  @override
  void initState() {
    super.initState();
    if (widget.appCastId != null) {
      chromecastController = ChromecastController();
      chromecastController?.currentTimeNotifier
          .addListener(_currentTimeListener);
      chromecastController?.sessionState.addListener(_sessionStateListener);
    }
    videoLoadingStyle = widget.videoLoadingStyle ?? VideoLoadingStyle();
    videoStyle = widget.videoStyle ?? VideoStyle();
    videoControlSetup(widget.url);

    /// Control bar animation
    controlBarAnimationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    controlTopBarAnimation = Tween(begin: -(36.0 + 0.0 * 2), end: 0.0)
        .animate(controlBarAnimationController);
    controlBottomBarAnimation = Tween(begin: -(36.0 + 0.0 * 2), end: 0.0)
        .animate(controlBarAnimationController);
    var widgetsBinding = WidgetsBinding.instance;

    widgetsBinding.addPostFrameCallback((callback) {
      widgetsBinding.addPersistentFrameCallback((callback) {
        if (!mounted) return;
        if (_fullscreen != fullScreen) {
          setState(() {
            fullScreen = !fullScreen;
            _navigateLocally(context);
            if (widget.onFullScreen != null) {
              widget.onFullScreen!(fullScreen);
            }
          });
        }
        widgetsBinding.scheduleFrame();
      });
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    super.dispose();
    controller!.dispose();
    chromecastController?.closeSession();
    WakelockPlus.disable();
  }

  void _currentTimeListener() {
    int value = chromecastController?.currentTimeNotifier.value ?? 0;
    if (value >= currentPosition) {
      currentPosition = value;
      if (widget.position != null) {
        widget.position!(currentPosition);
        if (currentPosition == controller!.value.duration.inSeconds) {
          chromecastController?.closeSession();
        }
      }
    }
  }

  void _sessionStateListener() async {
    setState(() {
      sessionState = chromecastController?.sessionState.value;
    });
    if (sessionState == CastSessionState.connected) {
      createHideControlBarTimer();
      if (controller!.value.isPlaying) {
        controller!.pause();
      }
      isOpenCastDialog = false;
      _updateState();
    } else if (sessionState == CastSessionState.closed) {
      await controller!.seekTo(Duration(seconds: currentPosition));
      _updateState();
    }
  }

  @override
  Widget build(BuildContext context) {
    _wasLoading = (isLoading(_latestValue) || !controller!.value.isInitialized);
   return _VideoPlayer(
     castDialog: castDialog(),
     isOpenCastDialog: isOpenCastDialog,
     closeChromecast: () {
       chromecastController?.closeSession();
     },
     castSessionState: sessionState,
     aspectRatio:
     fullScreen ? calculateAspectRatio(screenSize) : widget.aspectRatio,
     controller: controller!,
     appCastId: widget.appCastId,
     toggleControls: toggleControls,
     togglePlay: togglePlay,
     videoSeek: "$videoSeek",
     videoDuration: "$videoDuration",
     videoStyle: videoStyle,
     showMenu: showMenu,
     wasLoading: _wasLoading,
     fullScreen: fullScreen,
     toggleFullScreen: toggleFullScreen,
     onToNextVideo: widget.onToNextVideo,
     screenSize: screenSize,
     videoLoadingStyle: videoLoadingStyle,
     startHideTimer: _startHideTimer,
     cancelAndRestartTimer: cancelAndRestartTimer,
     onDragStart: () {
       _hideTimer?.cancel();
     },
     onTapCastBtn: _onTapCastBtn,
   );
  }

  void _onTapCastBtn() async {
    if (fullScreen) toggleFullScreen();
    createHideControlBarTimer();
    chromecastController?.devicesNotifier.value = [];
    if (fullScreen) await Future.delayed(const Duration(milliseconds: 900));
    if (controller!.value.isPlaying) {
      controller!.pause();
    }
    setState(() {
      isOpenCastDialog = true;
    });
  }

  Widget castDialog() {
    return CastDialog(
      isFullScreen: fullScreen,
      appId: widget.appCastId!,
      url: widget.url,
      videoTitle: widget.videoTitle!,
      startAt: currentPosition,
      controller: chromecastController!,
      closeDialog: () {
        setState(() {
          isOpenCastDialog = false;
        });
      },
    );
  }

  static const int _bufferingInterval = 20000;

  bool isLoading(VideoPlayerValue? latestValue) {
    if (latestValue != null) {
      if (!latestValue.isPlaying && latestValue.duration == null) {
        return true;
      }

      final Duration position = latestValue.position;

      Duration? bufferedEndPosition;
      if (latestValue.buffered.isNotEmpty == true) {
        bufferedEndPosition = latestValue.buffered.last.end;
      }

      if (bufferedEndPosition != null) {
        final difference = bufferedEndPosition - position;

        if (latestValue.isPlaying &&
            latestValue.isBuffering &&
            difference.inMilliseconds < _bufferingInterval) {
          return true;
        }
      }
    }
    return false;
  }

  void changePlayerControlsNotVisible(bool notVisible) {
    setState(() {
      controlsNotVisible = notVisible;
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(milliseconds: 3000), () {
      changePlayerControlsNotVisible(true);
    });
  }

  void cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    changePlayerControlsNotVisible(false);
  }

  // Video controller
  void videoControlSetup(String? url) {
    videoInit(url);
    controller!.addListener(listener);
    controller!.play();
  }

  // video Listener
  void listener() async {
    _updateState();
    if (controller!.value.isInitialized && controller!.value.isPlaying) {
      if (!await WakelockPlus.enabled) {
        await WakelockPlus.enable();
      }
      setState(() {
        videoDuration = convertDurationToString(controller!.value.duration);
        videoSeek = convertDurationToString(controller!.value.position);
        videoSeekSecond = controller!.value.position.inSeconds.toDouble();
        videoDurationSecond = controller!.value.duration.inSeconds.toDouble();
      });
    } else {
      if (await WakelockPlus.enabled) {
        await WakelockPlus.disable();
        setState(() {});
      }
    }
  }

  void _updateState() {
    if (mounted) {
      if (controller!.value.position.inSeconds != _position &&
          widget.position != null) {
        currentPosition = controller!.value.position.inSeconds;
        widget.position!(currentPosition);
      }
      if (isVideoFinished(controller!.value) ||
          _wasLoading ||
          isLoading(controller!.value)) {
        setState(() {
          _latestValue = controller!.value;
        });
      }
    }
  }

  bool isVideoFinished(VideoPlayerValue? videoPlayerValue) {
    return videoPlayerValue?.position != null &&
        videoPlayerValue?.duration != null &&
        videoPlayerValue!.position.inMilliseconds != 0 &&
        videoPlayerValue.duration.inMilliseconds != 0 &&
        videoPlayerValue.position >= videoPlayerValue.duration;
  }

  String convertDurationToString(Duration duration) {
    var minutes = duration.inMinutes.toString();
    if (minutes.length == 1) {
      minutes = '0$minutes';
    }
    var seconds = (duration.inSeconds % 60).toString();
    if (seconds.length == 1) {
      seconds = '0$seconds';
    }
    return "$minutes:$seconds";
  }

  void videoInit(String? url) async {
    controller = VideoPlayerController.networkUrl(Uri.parse(url!))
      ..initialize().then((value) {
        startAt();
        setState(() => hasInitError = false);
      }).catchError((e) => setState(() => hasInitError = true));
  }

  void startAt() async {
    if (widget.startAt != null) {
      await controller!.seekTo(widget.startAt!);
    }
  }

  void toggleControls() {
    clearHideControlBarTimer();

    if (!showMenu) {
      showMenu = true;
      createHideControlBarTimer();
    } else {
      showMenu = false;
    }
    setState(() {
      if (showMenu) {
        controlBarAnimationController.forward();
      } else {
        controlBarAnimationController.reverse();
      }
    });
  }

  void togglePlay() {
    createHideControlBarTimer();
    if (controller!.value.isPlaying) {
      controller!.pause();
    } else {
      controller!.play();
    }
    setState(() {});
  }

  void createHideControlBarTimer() {
    clearHideControlBarTimer();
    showTime = Timer(const Duration(milliseconds: 5000), () {
      if (controller != null && controller!.value.isPlaying) {
        if (showMenu) {
          setState(() {
            showMenu = false;
            controlBarAnimationController.reverse();
          });
        }
      }
    });
  }

  void clearHideControlBarTimer() {
    showTime?.cancel();
  }

  void _navigateLocally(context) async {
    if (!fullScreen) {
      if (ModalRoute.of(context)!.willHandlePopInternally) {
        Navigator.of(context).pop();
      }
      return;
    }
    ModalRoute.of(context)!
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: () {
      if (fullScreen) toggleFullScreen();
    }));
  }

  void toggleFullScreen() {
    if (fullScreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    }
    _fullscreen = !_fullscreen;
  }
}

class _VideoPlayer extends StatelessWidget {
  const _VideoPlayer({
    super.key,
    required this.fullScreen,
    required this.aspectRatio,
    required this.screenSize,
    required this.controller,
    required this.toggleControls,
    required this.togglePlay,
    required this.videoSeek,
    required this.videoDuration,
    required this.videoLoadingStyle,
    required this.videoStyle,
    required this.showMenu,
    required this.wasLoading,
    required this.toggleFullScreen,
    required this.startHideTimer,
    required this.cancelAndRestartTimer,
    required this.onDragStart,
    this.onToNextVideo,
    this.appCastId,
    this.videoTitle,
    required this.onTapCastBtn,
    required this.closeChromecast,
    this.castSessionState,
    required this.isOpenCastDialog,
    required this.castDialog,
  });

  final bool fullScreen;
  final bool showMenu;
  final bool wasLoading;
  final Size screenSize;
  final double aspectRatio;
  final String videoSeek;
  final String videoDuration;
  final String? appCastId;
  final String? videoTitle;
  final VideoLoadingStyle videoLoadingStyle;
  final VideoStyle videoStyle;
  final VideoPlayerController controller;
  final CastSessionState? castSessionState;
  final bool isOpenCastDialog;

  final Function() toggleFullScreen;
  final Function() startHideTimer;
  final Function() cancelAndRestartTimer;
  final Function() onDragStart;
  final Function()? onToNextVideo;
  final Function() toggleControls;
  final Function() togglePlay;
  final Function() onTapCastBtn;
  final Function() closeChromecast;
  final Widget castDialog;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: fullScreen ? calculateAspectRatio(screenSize) : aspectRatio,
      child: Stack(
        children: [
          VideoWidget(
            controller: controller,
            onTap: toggleControls,
            onDoubleTap: togglePlay,
          ),
          castSessionState == CastSessionState.connected
              ? Container(
                  color: Colors.black38,
                  child: Center(
                    child: InkWell(
                      onTap: closeChromecast,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Cerrar Chromecast",
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(
                              Icons.cast_outlined,
                              color: Colors.grey,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : ControlsWidget(
                  castDialog: castDialog,
                  onTapCastBtn: onTapCastBtn,
                  videoTitle: videoTitle,
                  appCastId: appCastId,
                  videoSeek: videoSeek,
                  videoDuration: videoDuration,
                  style: videoLoadingStyle,
                  videoStyle: videoStyle,
                  controller: controller,
                  showMenu: showMenu,
                  wasLoading: wasLoading,
                  fullScreen: fullScreen,
                  toggleControls: toggleControls,
                  togglePlay: togglePlay,
                  toggleFullScreen: toggleFullScreen,
                  onDragEnd: startHideTimer,
                  onTapDown: cancelAndRestartTimer,
                  onToNextVideo: onToNextVideo,
                  onDragStart: onDragStart,
                  isOpenCastDialog: isOpenCastDialog,
                )
        ],
      ),
    );
  }
}
