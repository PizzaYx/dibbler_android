import 'dart:async';
import 'dart:io';
import 'package:dibbler_android/entities.dart';
import 'package:dibbler_android/sqlStore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'Interface.dart';

class VideoController extends GetxController {
  late VideoPlayerController videoPlayerController;

//-------------时间控制--------
  //标题显示时间
  int titleTime = 10;

  //倒计时播放时间
  var countTimer = 10.obs;

  //随机观看时长S
  int randomTime = 40;

//---------------------------

  //是否正在播放
  bool isPlaying = false;

  //是否自动播放
  bool isAutoPlay = true;

  //随机播放时长定时器
  Timer? timer;

  //播放视频倒计时
  Timer? timerCountDown;

  //标题显示
  var isShowTitle = true.obs;

  //判断是倒计时还是播放视频 false为倒计时
  var isVideoCountDown = false.obs;

  //指定播放视频列表
  List<PlayVideo> videoList = [];

  // random播放的 videoUrl
  String randomVideoUrl = '';
  String randomVideoTitle = '';

  //当前要播放的视频地址和标题
  var nowVideoUrl = ''.obs;
  var nowVideoTitle = ''.obs;

  @override
  void onInit() {
    playCountDown();
    super.onInit();
  }

  //播放器倒计时
  void playCountDown() {
    //倒计时a秒结束后 播放视频
    timerCountDown = Timer.periodic(const Duration(seconds: 1), (timer) {
      countTimer.value--;
      if (countTimer.value == 6) {
        setAutoPlayUrlTitle();
        isShowTitle.value = false;
      }

      if (countTimer.value <= 0) {
        timer.cancel();
        isVideoCountDown.value = true;
      }
    });
  }

  //重置倒计时
  void resetCountDown() {
    isVideoCountDown.value = false;
    isShowTitle.value = true;
    //
    countTimer.value = 10;
    timerCountDown?.cancel();
    playCountDown();
  }

  // 设置随机播放的视频
  void setAutoPlayUrlTitle() async {
    List<String> data = await SqlStore.to.queryUrlTitle();
    if (data.isNotEmpty) {
      randomVideoUrl = data[0];
      randomVideoTitle = data[1];
    }
  }

  //设置指定播放视频列表
  Future<void> setVideoList(List<PlayVideo> data) async {
    videoList.clear();
    if (data.isEmpty) {
      isAutoPlay = true;
    } else {
      isAutoPlay = false;
      videoList = data;
      nowVideoUrl.value = await SqlStore.to.queryUrl(videoList[0].videoId);
      nowVideoTitle.value = videoList[0].title;
    }
  }

  //视频初始化
  void initializeVideoPlayer() async {
    if (isAutoPlay) {
      nowVideoUrl.value = randomVideoUrl;
      nowVideoTitle.value = randomVideoTitle;
    }

    videoPlayerController = VideoPlayerController.file(File(nowVideoUrl.value))
      ..addListener(() {
        final bool playing = videoPlayerController.value.isPlaying;
        if (playing != isPlaying) {
          isPlaying = playing;
        }
        // 检查视频是否播放结束
        if (videoPlayerController.value.position >=
            videoPlayerController.value.duration) {
          // 视频播放结束，可以在这里执行相应的逻辑
          videoPlayerController.dispose();
          resetCountDown();
          delVideoPlayList(videoList[0].id);
        }
      })
      ..initialize().then((_) {
        videoPlayerController.play();
        isPlaying = true;
        if (isAutoPlay) {
          Timer(const Duration(seconds: 5), () {
            setAutoPlayUrlTitle();
          });

          timer = Timer(Duration(seconds: randomTime), () {
            videoPlayerController.dispose();
            isPlaying = false;
            resetCountDown();
          });
        }
      });
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    timer?.cancel();
    super.onClose();
  }
}

//---------------------------------------------
class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with SingleTickerProviderStateMixin {
  VideoController get ct => Get.find<VideoController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Obx(
        () {
          if (ct.countTimer.value == 0) {
            // 初始化视频的逻辑
            ct.initializeVideoPlayer();
            // return VideoPlayer(ct.videoPlayerController);
            return Center(
              child: Stack(
                children: <Widget>[
                  AspectRatio(
                      aspectRatio: 16.0 / 9.0,
                      child: VideoPlayer(ct.videoPlayerController)),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ct.isShowTitle.value == true
                        ? Container(
                            height: 39.h,
                            padding: EdgeInsets.only(left: 15.w),
                            // 设置左边距
                            alignment: Alignment.centerLeft,
                            // 设置文字垂直居中并且靠左显示
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(29, 31, 56, 0.5),
                            ),
                            child: Text(
                              ct.nowVideoTitle.value,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 15.sp),
                            ),
                          )
                        : Container(),
                  )
                ],
              ),
            );
          } else {
            // 显示倒计时文本的逻辑
            return Center(
              child: Text(
                "倒计时: ${ct.countTimer.value} 播放",
                style: TextStyle(color: Colors.white, fontSize: 20.sp),
              ),
            );
          }
        },
      ),
    );
  }
}

//---------------------------------------------
// gradient: LinearGradient(
//   begin: Alignment.topCenter,
//   end: Alignment.bottomCenter,
//   colors: [
//     Color.fromRGBO(29, 31, 56, 1),
//     Color.fromRGBO(29, 31, 56, 0),
//   ],
// ),
