import 'dart:async';
import 'dart:io';
import 'package:dibbler_android/sqlStore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController {
  late VideoPlayerController videoPlayerController;
  var isPlaying = false.obs;
  var isAutoPlay = true.obs;
  Timer? timer;

  // 指定播放的 videoUrl
  String videoUrl = '';
  String videoTitle = '';

  // 指定播放的 videoUrl 方法
  void setVideoUrl(String url, String title) {
    isAutoPlay.value = false;
    videoUrl = url;
    videoTitle = title;
    initializeVideoPlayer();
  }

  // 如果随机播放 获取值
  void setAutoPlayUrlTitle() async {
    List<String> data = await SqlStore.to.queryUrlTitle();
    if (data.isNotEmpty) {
      videoUrl = data[0];
      videoTitle = data[1];
    }
  }

  void initializeVideoPlayer() async {
    videoPlayerController = VideoPlayerController.file(File(videoUrl))
      ..addListener(() {
        final bool playing = videoPlayerController.value.isPlaying;
        if (playing != isPlaying.value) {
          isPlaying.value = playing;
        }
        // 检查视频是否播放结束
        if (videoPlayerController.value.position >=
            videoPlayerController.value.duration) {
          // 视频播放结束，可以在这里执行相应的逻辑

          // isAutoPlay.value = true;
        }
      })
      ..initialize().then((_) {
        videoPlayerController.play();
        isPlaying.value = true;
        //如果isAutoPlay为true，3分钟后暂停视频 为false时不暂停
        if (isAutoPlay.value) {
          timer = Timer(const Duration(minutes: 1), () {
            videoPlayerController.pause();
            isPlaying.value = false;
            initializeVideoPlayer();
          });
        }
      });
  }

  void changeVideo(String newUrl, String newTitle) {
    videoPlayerController.pause();
    timer?.cancel();
    setVideoUrl(newUrl, newTitle);
    initializeVideoPlayer();
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    timer?.cancel();
    super.onClose();
  }
}

class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VideoController>(
      init: VideoController()..initializeVideoPlayer(),
      builder: (controller) {
        return VideoPlayer(controller.videoPlayerController);
      },
    );
  }
}
