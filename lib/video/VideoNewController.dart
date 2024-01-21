import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../Interface.dart';

class VideoController extends GetxController {
  VideoPlayerController? videoPlayerController;

  // 是否自动播放
  var isAutoPlay = true.obs;

  // 倒计时
  late Timer countdownTimer;

  // 随机播放时长定时器
  // Timer? timer;

  // 随机观看时长
  int randomTime = 15;

  // 倒计时数
  var countdownDuration = 10.obs;

  // 定义一个标志，用于判断是否需要执行倒计时
  var shouldStartCountdown = false.obs;

  // 视频链接
  String videoUrl = '';

  // 视频标题
  String videoTitle = '';

  @override
  void onInit() {
    super.onInit();
    setAutoPlayUrlTitle();
    // 初始化视频控制器
    initializeVideoPlayerController(videoUrl);
  }

  // 设置随机播放的视频
  void setAutoPlayUrlTitle() async {
    videoUrl = ct.sixVideoList[ct.randomIndex.value].localPath;
    videoTitle = ct.sixVideoList[ct.randomIndex.value].title;
  }

  // 初始化或切换视频地址
  void initializeVideoPlayerController(String videoPath) {
    if (videoPath.isEmpty) {
      // 如果 videoPath 为空，直接返回
      return;
    }

    if (videoPlayerController != null) {
      // 如果 videoPlayerController 已初始化，则切换视频地址
      videoPlayerController!.pause();
      videoPlayerController!.seekTo(Duration.zero);
      videoPlayerController!.dispose();
    }

    videoPlayerController = VideoPlayerController.file(File(videoPath))
      ..initialize().then((_) {
        if (videoPlayerController!.value.isInitialized) {
          videoPlayerController!.play();
          videoPlayerController!.addListener(videoEndListener);
        } else {
          // 处理视频初始化失败的情况
          print('视频源错误');
        }
      });
  }

  // 视频播放结束监听
  void videoEndListener() {
    print(
        'videoPlayerController!.value.position ---- ${videoPlayerController!.value.position}');

    //如果随机播放
    if (videoPlayerController!.value.position >= const Duration(seconds: 15) &&
        isAutoPlay.value == true) {
      //结束和暂停视频
      videoPlayerController!.pause();
      videoPlayerController!.seekTo(Duration.zero);
      videoPlayerController!.dispose();
      videoPlayerController = null;
      //开始倒计时
      startCountdown();
    }

    //如果正常播放
    if (videoPlayerController!.value.position ==
            videoPlayerController!.value.duration &&
        isAutoPlay.value == false) {
      // 视频播放结束，启动倒计时
      if (shouldStartCountdown.value) {
        //结束和暂停视频
        videoPlayerController!.pause();
        videoPlayerController!.seekTo(Duration.zero);
        videoPlayerController!.dispose();
        videoPlayerController = null;
        startCountdown();
      }
    }
  }

  // 启动倒计时
  void startCountdown() {
    shouldStartCountdown.value = true;
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdownDuration--;
      print('countdownDuration ----- $countdownDuration');
      if (countdownDuration.value == 0) {
        // 倒计时结束，切换到新的视频地址
        shouldStartCountdown.value = false;
        countdownTimer.cancel();

        if (isAutoPlay.value) {
          onAutoComplete();
        } else {
          //稍后处理
        }
      }
    });
  }

  // 重置倒计时
  void resetCountdown() {
    countdownDuration.value = 10;
  }

  //随机播放后逻辑
  void onAutoComplete() {
    // 切换到新的视频地址
    if (ct.randomIndex.value == (ct.sixVideoList.length - 1)) {
      //重新获取6个视频
      ct.querySixDownload().then((value) => {
        ct.randomIndex.value = 0
      });
    } else {
      ct.randomIndex.value++;
    }
    setAutoPlayUrlTitle();
    initializeVideoPlayerController(videoUrl);
    // 重置倒计时
    resetCountdown();
  }

  @override
  void dispose() {
    // 在控制器销毁时，释放 VideoPlayerController 和计时器
    videoPlayerController!.dispose();
    countdownTimer.cancel();
    super.dispose();
  }
}
