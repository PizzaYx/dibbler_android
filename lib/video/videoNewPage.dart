import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'VideoNewController.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final VideoController videoController = Get.put(VideoController());

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Obx(
        () {
          return Stack(
            children: [
              // 视频播放器部分
              Positioned.fill(
                child: videoController.videoPlayerController != null ? AspectRatio(
                  aspectRatio: 16.0 / 9.0,
                  child: VideoPlayer(videoController.videoPlayerController!),
                ):Container(),
              ),
              // 倒计时部分
              if (videoController.shouldStartCountdown.value)
                Positioned.fill(
                  child: Center(
                    child: Text(
                      "倒计时: ${videoController.countdownDuration} s",
                      style: TextStyle(color: Colors.white, fontSize: 24.0),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
