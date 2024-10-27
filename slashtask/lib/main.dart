import 'package:flutter/material.dart';
import 'package:slashtask/view/video_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      title: 'Video Playback Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  VideoView(
        videoPaths:const  [
          'assets/videos/video1.mp4',
          'assets/videos/video2.mp4',
          'assets/videos/video3.mp4',
        ],
      ),
    );
  }
}
