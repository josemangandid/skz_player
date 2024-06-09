import 'package:flutter/material.dart';
import 'package:skz_player/skz_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static const String url =
      "https://moodle1.myyschool.xyz/MXE1MDdTT3dhQUxwZEs2SDF6d2RHOXJFYVJ6NElFNUFVVEd4MjdiQWFWOWNqUDVyTU5aaGpzbnB1QlNoY2s0Rg.m3u8";
  static const String url2 = "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isFullScreen = false;

  setIsFullScreen(bool value) {
    if (isFullScreen != value) {
      setState(() {
        isFullScreen = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('SkzPlayer Example')),
        body: Center(
          child: SkzPlayer(
            videoTitle: "CustomTitle",
            appCastId: "1E79D581",
            url: MyApp.url,
            position: (int position){
              print("Position: $position");
            },
          ),
        ),
      ),
    );
  }
}
