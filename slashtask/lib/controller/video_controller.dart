import 'dart:async';
import 'package:flutter/material.dart';
import 'package:slashtask/model/video_model.dart';
import 'dart:developer'; 


class VideoController {
  final VideoRepository repository;
  Timer? _timer;

  VideoController({required this.repository});

  void initialize() async {
    await repository.initializeAll();
    _startPlaybackSequence();
  }

  void _startPlaybackSequence() {
    _playVideoWithTimer(0, 16, () {
      repository.currentVideo.controller.pause();
      _playVideoWithTimer(1, 21, () {
        repository.currentVideo.controller.pause();
        _playThirdVideo();
      });
    });
  }

  void _playThirdVideo() {
    repository.setCurrentIndex(2);
    _playCurrentVideo();

    _addCompletionListener(() {
      _resumeSecondVideo();
    });
  }

  void _resumeSecondVideo() {
    repository.setCurrentIndex(1);
    _playCurrentVideo();

    _addCompletionListener(() {
      _resumeFirstVideo();
    });
  }

  void _resumeFirstVideo() {
    repository.setCurrentIndex(0);
    _playCurrentVideo();

    _addCompletionListener(() {
      _resetAllVideos();
      _startPlaybackSequence();
    });
  }

  void _playVideoWithTimer(int videoIndex, int seconds, VoidCallback onComplete) {
    repository.setCurrentIndex(videoIndex);
    _playCurrentVideo();
    _timer = Timer(Duration(seconds: seconds), () {
      repository.currentVideo.controller.pause();
      onComplete();
    });
  }

  void _playCurrentVideo() {
    if (repository.currentVideo.controller.value.isInitialized) {
      repository.currentVideo.controller.play();
    } else {
      log("Error: Attempting to play an uninitialized video." );
    }
  }

  void _addCompletionListener(VoidCallback onComplete) {
    repository.currentVideo.controller.removeListener(onComplete);
    repository.currentVideo.controller.addListener(() {
      if (repository.currentVideo.controller.value.isInitialized &&
          repository.currentVideo.controller.value.position ==
              repository.currentVideo.controller.value.duration) {
        onComplete();
      }
    });
  }

  void _resetAllVideos() {
    for (var videoData in repository.videos) {
      videoData.controller.seekTo(Duration.zero);
      videoData.controller.pause();
    }
  }

  void dispose() {
    for (var videoData in repository.videos) {
      videoData.controller.dispose();
    }
    _timer?.cancel();
  }
}
