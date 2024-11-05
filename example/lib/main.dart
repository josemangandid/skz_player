import 'package:flutter/material.dart';
import 'package:skz_player/skz_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static const String url =
      "https://nika.playmudos.com/ZzRLL216cnlINGVGbEdMZGI0VzRTNXRCN2ZleGVtZEhxRnAyZHplaFU4T1ZBck0zclVmVWVsMkxZeEhHNExHaA.m3u8";
  static const String referer = "https://jkanime.net/rekishi-ni-nokoru-akujo-ni-naru-zo/6/";
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
        appBar: isFullScreen ? null:  AppBar(title: const Text('SkzPlayer Example')),
        body: Center(
          child: SkzPlayer(
            videoTitle: "CustomTitle",
            appCastId: "1E79D581",
            url: MyApp.url,
            headers: const {
              "Referer": MyApp.referer,
            },
            onFullScreen: setIsFullScreen,
            position: (int position){
              print("Position: $position");
            },
          ),
        ),
      ),
    );
  }
}
