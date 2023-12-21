import 'dart:async';
import 'dart:io';
import 'package:dibbler_android/entities.dart';
import 'package:dibbler_android/scrollingText.dart';
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
  var countTimer = 12.obs;

  //随机观看时长S
  int randomTime = 30;

//---------------------------

  //是否自动播放
  var isAutoPlay = true.obs;

  //随机播放时长定时器
  Timer? timer;

  //播放视频倒计时
  Timer? timerCountDown;

  //标题显示
  var isShowTitle = true.obs;

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
      //倒计时6秒时获取下次随机播放视频
      if (countTimer.value == 6) {
        setAutoPlayUrlTitle();
      }
      isShowTitle.value = true;
      if (countTimer.value <= 0) {
        showTitleCountDown();
        //关闭定时器
        timerCountDown?.cancel();
      }
    });
  }

  //显示标题倒计时
  void showTitleCountDown() {
    Timer(Duration(seconds: titleTime), () {
      // 在10秒后执行的函数
      isShowTitle.value = false;
    });
  }

  //重置倒计时
  void resetCountDown({int time = 15}) {
    countTimer.value = time;
    timerCountDown?.cancel();
    playCountDown();
  }

  // 设置随机播放的视频
  void setAutoPlayUrlTitle() async {
    List<String> data = await SqlStore.to.queryUrlTitle();
    if (data.isNotEmpty) {
      //如果倒计时结束并且没有在播放视频 就重置倒计时
      if (randomVideoUrl == '' && timerCountDown?.isActive != true) {
        resetCountDown();
      }
      randomVideoUrl = data[0];
      randomVideoTitle = data[1];
    }
  }

  // 获取 后设置缓存播放列表 和 跑马灯数据
  void getVideoList() async {
    List<Map<String, Object?>> resultSet = await SqlStore.to.queryAllOrders();
    List<PlayVideo> data = [];
    for (int i = 0; i < resultSet.length; i++) {
      PlayVideo movie = PlayVideo(
        resultSet[i]['videoId'] as String,
        resultSet[i]['id'] as String,
        resultSet[i]['title'] as String,
        resultSet[i]['nickname'] as String,
        resultSet[i]['truename'] as String,
        resultSet[i]['createTime'] as String,
        isplay: resultSet[i]['isplay'] as int,
      );
      data.add(movie);
    }

    String moveString = '';
    if (data.isNotEmpty) {
      isAutoPlay.value = false;
      videoList = data;
      setVideoListStatus();
      //设置跑马灯数据
      final ScrollingTextController sc = Get.find<ScrollingTextController>();
      for (int i = 0; i < data.length; i++) {
        if (i == 0) {
          moveString += '当前播放: ${data[i].nickname} [${data[i].title}] ';
        } else {
          moveString += '稍后播放: ${i}:${data[i].nickname}[${data[i].title}] ';
        }
        if (i != data.length - 1) {
          moveString += "   ";
        }
      }
      sc.changeText(moveString);
    } else {
      isAutoPlay.value = true;
      // resetCountDown();
    }
  }

  //设置订单播放视频列表的状态
  void setVideoListStatus() async {
    //判断是否有isplay = 1的数据 有就不执行下边的代码
    bool isPlay = await SqlStore.to.queryIsPlay();
    if (isPlay && nowVideoUrl.value != '') {
      return;
    } else {
      //设置不自动播放
      isAutoPlay.value = false;
      //更具video查询localPath
      nowVideoUrl.value =
          await SqlStore.to.queryLocalPath(videoList[0].videoId);
      nowVideoTitle.value = videoList[0].title;
      //设置当前播放视频的状态为已播放
      SqlStore.to.updateOrders(videoList[0].id, 1);
      videoPlayerController.dispose();
      //判断是否在倒计时
      if (timerCountDown?.isActive != true) {
        resetCountDown();
      }
    }
  }

  //视频初始化
  void initializeVideoPlayer() async {
    //如果自动播放使用随机播放链接
    if (isAutoPlay.value == true) {
      nowVideoUrl.value = randomVideoUrl;
      nowVideoTitle.value = randomVideoTitle;
    }

    videoPlayerController = VideoPlayerController.file(File(nowVideoUrl.value))
      ..addListener(() {
        // 检查视频是否播放结束
        if (isAutoPlay.value == false &&
            videoPlayerController.value.position != Duration.zero &&
            videoPlayerController.value.position >=
                videoPlayerController.value.duration) {
          // 视频播放结束，可以在这里执行相应的逻辑
          videoPlayerController.dispose();
          nowVideoUrl.value = '';
          nowVideoTitle.value = '';
          // //继续倒计时
          resetCountDown();
          //与服务器同步移除当前播放的视频
          delVideoPlayList(videoList[0].id);
          SqlStore.to.deleteOrders(videoList[0].id).then((value) {
            getVideoList();
          });
        }
      })
      ..initialize().then((_) {
        videoPlayerController.play();

        if (isAutoPlay.value) {
          timer = Timer(Duration(seconds: randomTime), () {
            videoPlayerController.dispose();
            resetCountDown();
            timer?.cancel();
          });
        }
      });
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    timer?.cancel();
    timerCountDown?.cancel();
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
          if (ct.countTimer.value == 0 && ct.randomVideoUrl != '') {
            // 初始化视频的逻辑
            ct.initializeVideoPlayer();
            // return VideoPlayer(ct.videoPlayerController);
            return Center(
              child: Stack(
                children: <Widget>[
                  SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: VideoPlayer(ct.videoPlayerController)),
                  // AspectRatio(
                  //     aspectRatio: 16.0 / 9.0,
                  //     child: VideoPlayer(ct.videoPlayerController)),
                  Obx(() => Positioned(
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
                      ))
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
