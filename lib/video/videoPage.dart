import 'package:dibbler_android/video/videoController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../home/homeController.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with SingleTickerProviderStateMixin {
  VideoController get vct => Get.find<VideoController>();

  HomeController get ct => Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Obx(
        () {
          if (ct.sixVideoList.length == 6 && vct.isCountDown.value == false) {
            // 初始化视频的逻辑
            vct.setAutoPlayUrlTitle();
            vct.initializeVideoPlayer();
            // return VideoPlayer(ct.videoPlayerController);
            return Center(
              child: Stack(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: AspectRatio(
                        aspectRatio: 16.0 / 9.0,
                        child: VideoPlayer(vct.videoPlayerController)),
                  ),
                ],
              ),
            );
          } else {
            // 显示倒计时文本
            return Center(
              child: Text(
                "倒计时: ${vct.countTimer.value} 播放",
                style: TextStyle(color: Colors.white, fontSize: 50.sp),
              ),
            );
          }
        },
      ),
    );
  }
}
