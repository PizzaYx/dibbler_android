import 'dart:async';
import 'dart:io';

import 'package:dibbler_android/tools/sqlStore.dart';
import 'package:dibbler_android/video/videoFullScreen.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../tools/Interface.dart';

class VideoController extends GetxController {
  VideoPlayerController? videoPlayerController;

  // 私有构造函数
  VideoController._();

  // 单例实例
  static final VideoController _instance = VideoController._();

  // 静态方法来获取实例
  static VideoController get instance => _instance;

  // 倒计时
  Timer? countdownTimer;

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

  //有订单数据时 处理逻辑
  void payVideoLogic() {
    //如果视频当前在播放就停止
    if (ct.payVideo.isNotEmpty) {
      ct.isAutoPlay.value = false;
      Get.to(() => const VideoFullScreen());
      stopAutoPlay();
    } else {
      ct.isAutoPlay.value = true;
    }
  }

  // 视频播放结束监听
  void videoEndListener() {
    print(
        'videoPlayerController!.value.position ---- ${videoPlayerController!.value.position}');

    print(
        'videoPlayerController!.value.duration ---- ${videoPlayerController!.value.duration}');

    //如果随机播放
    if (videoPlayerController!.value.position < const Duration(seconds: 16) &&
        videoPlayerController!.value.position >= const Duration(seconds: 15) &&
        ct.isAutoPlay.value == true) {
      //结束和暂停视频
      videoPlayerController!.pause();
      videoPlayerController!.dispose();
      videoPlayerController = null;
      //开始倒计时
      startCountdown();
    }

    //如果正常播放
    if (videoPlayerController!.value.position ==
            videoPlayerController!.value.duration &&
        ct.isAutoPlay.value == false) {
      // 视频播放结束，启动倒计时
      if (shouldStartCountdown.value) {
        //结束和暂停视频
        videoPlayerController!.pause();
        videoPlayerController!.dispose();
        videoPlayerController = null;
        //删除订单视频
        delVideoPlayList(ct.payVideo[0].id);
        //获取有没有订单视频
        ct.getVideoHorseList();
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
        countdownTimer!.cancel();
        if (ct.isAutoPlay.value) {
          onAutoComplete();
        } else {
          onPayVideoComplete();
        }
      }
    });
  }

  //如果在随机播放中 获取到订单视频 就停止播放开始倒计时
  void stopAutoPlay() {
    //并且定时器没有被创建
    if (shouldStartCountdown.value == false || countdownTimer == null ) {
      //结束和暂停视频
      if(videoPlayerController!=null)
        {
          videoPlayerController!.pause();
          videoPlayerController!.seekTo(Duration.zero);
          videoPlayerController!.dispose();
          videoPlayerController = null;
        }
      //开始倒计时
      startCountdown();
    }
  }

  // 重置倒计时
  void resetCountdown() {
    countdownDuration.value = 10;
  }

  //点播播放视频逻辑
  Future<void> onPayVideoComplete() async {
    if (ct.payVideo.isNotEmpty) {
      videoUrl = await SqlStore.to.queryLocalPath(ct.payVideo[0].videoId);
      videoTitle = ct.payVideo[0].title;
    }

    //开始跑马灯
    ct.getVideoHorseList();
    initializeVideoPlayerController(videoUrl);
    // 重置倒计时
    resetCountdown();
  }

  //随机播放后逻辑
  void onAutoComplete() {
    // 切换到新的视频地址
    if (ct.randomIndex.value == (ct.sixVideoList.length - 1)) {
      //重新获取6个视频
      ct.querySixDownload().then((value) => {ct.randomIndex.value = 0});
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
    countdownTimer!.cancel();
    super.dispose();
  }
}
