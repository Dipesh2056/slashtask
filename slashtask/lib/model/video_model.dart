import 'dart:developer'; 


import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoData {
  final String title;
  final VideoPlayerController controller;

  VideoData({required this.title, required this.controller});
}

class VideoRepository extends ChangeNotifier {
  List<VideoData> videos = [];
  int _currentVideoIndex = 0;

  VideoRepository(List<String> videoPaths) {
    for (int i = 0; i < videoPaths.length; i++) {
      var controller = VideoPlayerController.asset(videoPaths[i]);
      videos.add(
        VideoData(
          title: 'Video ${i + 1}',
          controller: controller,
        ),
      );
    }
  }

  VideoData get currentVideo => videos[_currentVideoIndex];

  int get currentIndex => _currentVideoIndex;

  void setCurrentIndex(int index) {
    _currentVideoIndex = index;
    notifyListeners();
  }

  void nextVideo() {
    if (_currentVideoIndex < videos.length - 1) {
      _currentVideoIndex++;
    }
    notifyListeners();
  }

  void previousVideo() {
    if (_currentVideoIndex > 0) {
      _currentVideoIndex--;
    }
    notifyListeners();
  }

  Future<void> initializeAll() async {
    for (var videoData in videos) {
      try {
        await videoData.controller.initialize();
      } catch (e) {
        log("Error initializing video: ${videoData.title}, error: $e" );
      }
    }
  }
}
