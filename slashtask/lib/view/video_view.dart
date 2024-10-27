import 'package:flutter/material.dart';
import 'package:slashtask/controller/video_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../model/video_model.dart';
import 'dart:async';


class VideoView extends StatefulWidget {
  final List<String> videoPaths;

  VideoView({required this.videoPaths});

  @override
  _VideoViewState createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> with WidgetsBindingObserver {
  late VideoController _videoController;
  late VideoRepository _videoRepository;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _videoRepository = VideoRepository(widget.videoPaths);
    _videoController = VideoController(repository: _videoRepository);
    WidgetsBinding.instance.addObserver(this);
    _videoController.initialize();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _videoController.repository.currentVideo.controller.pause();
    } else if (state == AppLifecycleState.resumed) {
      // Optionally resume playback if desired
      // _videoController.repository.currentVideo.controller.play();
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _videoRepository,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Consumer<VideoRepository>(
            builder: (context, repo, child) {
              return Text('Playing: ${repo.currentVideo.title}');
            },
          ),
        ),
        body: Consumer<VideoRepository>(
          builder: (context, repo, child) {
            var video = repo.currentVideo;

            Duration currentTime = video.controller.value.position;
            Duration totalDuration = video.controller.value.duration;

            return Container(
              color: const Color.fromARGB(255, 124, 116, 84),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: video.controller.value.aspectRatio,
                    child: VideoPlayer(video.controller),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatDuration(currentTime),
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        Text(
                          formatDuration(totalDuration),
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: VideoProgressIndicator(
                      video.controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        backgroundColor: Colors.grey,
                        bufferedColor: Color.fromARGB(255, 26, 28, 29),
                        playedColor: Colors.blue,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          video.controller.play();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text('Play'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          video.controller.pause();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        icon: const Icon(Icons.pause, color: Colors.white),
                        label: const Text('Pause'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
