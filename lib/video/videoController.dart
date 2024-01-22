// import 'dart:async';
// import 'dart:io';
// import 'package:dibbler_android/entities.dart';
// import 'package:dibbler_android/view/scrollingText.dart';
// import 'package:dibbler_android/tools/sqlStore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';
//
// import '../Interface.dart';
// import '../home/homeController.dart';
//
// //视频播放管理器 非全屏下
// class VideoController extends GetxController {
//   late VideoPlayerController videoPlayerController;
//
//   //-------------随机播放--------
//   //随机观看时长S
//   int randomTime = 15;
//
//   //随机播放时长定时器
//   Timer? timer;
//
//   // random播放的 videoUrl
//   String randomVideoUrl = '';
//
//   String randomVideoTitle = '';
//
//   //-------------全屏播放-------------
//
//   //标题显示
//   //var isShowTitle = true.obs;
//   //指定播放视频列表
//   List<PlayVideo> videoList = [];
//
//   //-------------公共----------------
//   // 全屏下标题显示时间
//   //int titleTime = 10;
//
//   //当前要播放的视频地址和标题
//   var nowVideoUrl = ''.obs;
//   var nowVideoTitle = ''.obs;
//
//   //倒计时播放时间
//   var countTimer = 5.obs;
//
//   //是否自动播放
//   var isAutoPlay = true.obs;
//
//   //播放视频倒计时
//   Timer? timerCountDown;
//
//   //显示倒计时true 显示video false
//   var isCountDown = false.obs;
//
// //---------------------------
//
//   @override
//   void onInit() {
//     super.onInit();
//   }
//
//   //播放器倒计时
//   void playCountDown() {
//     timerCountDown?.cancel();
//     //倒计时a秒结束后 播放视频
//     timerCountDown = Timer.periodic(const Duration(seconds: 1), (timer) {
//       countTimer.value--;
//       print('倒计时----------$countTimer');
//       //如果随机播放的视频数量达到6组就重新获取重置
//       if (countTimer.value == 5 &&
//           ct.randomIndex.value == (ct.sixVideoList.length - 1)) {
//         //随机获取6组数据
//         ct.querySixDownload();
//       }
//
//       if (countTimer.value <= 0) {
//         isCountDown.value = false;
//
//         // showTitleCountDown();
//         //关闭定时器
//         timerCountDown?.cancel();
//       }
//     });
//   }
//
//   //显示标题倒计时
//   // void showTitleCountDown() {
//   //   Timer(Duration(seconds: titleTime), () {
//   //     // 在10秒后执行的函数
//   //     isShowTitle.value = false;
//   //   });
//   // }
//
//   //重置倒计时
//   void resetCountDown({int time = 5}) {
//     countTimer.value = time;
//     isCountDown.value = true;
//     playCountDown();
//   }
//
//   // 设置随机播放的视频
//   void setAutoPlayUrlTitle() async {
//     randomVideoUrl = ct.sixVideoList[ct.randomIndex.value].localPath;
//     randomVideoTitle = ct.sixVideoList[ct.randomIndex.value].title;
//   }
//

//
//   //设置订单播放视频列表的状态
//   void setVideoListStatus() async {
//     //判断是否有isplay = 1的数据 有就不执行下边的代码
//     bool isPlay = await SqlStore.to.queryIsPlay();
//     if (isPlay && nowVideoUrl.value != '') {
//       return;
//     } else {
//       //设置不自动播放
//       isAutoPlay.value = false;
//       //更具video查询localPath
//       nowVideoUrl.value =
//           await SqlStore.to.queryLocalPath(videoList[0].videoId);
//       nowVideoTitle.value = videoList[0].title;
//       //设置当前播放视频的状态为已播放
//       SqlStore.to.updateOrders(videoList[0].id, 1);
//       videoPlayerController.dispose();
//       //判断是否在倒计时
//       if (timerCountDown?.isActive != true) {
//         resetCountDown();
//       }
//     }
//   }
//
//   //视频初始化
//   void initializeVideoPlayer() async {
//     //如果自动播放使用随机播放链接
//     if (isAutoPlay.value == true) {
//       nowVideoUrl.value = randomVideoUrl;
//       nowVideoTitle.value = randomVideoTitle;
//     }
//
//     videoPlayerController = VideoPlayerController.file(File(nowVideoUrl.value))
//       ..addListener(() {
//         // 检查视频是否播放结束
//         if (isAutoPlay.value == false &&
//             videoPlayerController.value.position != Duration.zero &&
//             videoPlayerController.value.position >=
//                 videoPlayerController.value.duration) {
//           //点播播放
//           // 视频播放结束，可以在这里执行相应的逻辑
//           videoPlayerController.dispose();
//           nowVideoUrl.value = '';
//           nowVideoTitle.value = '';
//           // 重置倒计时
//           resetCountDown();
//           //与服务器同步移除当前播放的视频
//           delVideoPlayList(videoList[0].id);
//           SqlStore.to.deleteOrders(videoList[0].id).then((value) {
//             getVideoList();
//           });
//         }
//       })
//       ..initialize().then((_) {
//         //随机播放
//         videoPlayerController.play();
//         if (isAutoPlay.value) {
//           timer = Timer(Duration(seconds: randomTime), () {
//             videoPlayerController.pause();
//             videoPlayerController.dispose();
//             if (ct.randomIndex.value >= ct.sixVideoList.length) {
//               ct.randomIndex.value = 0;
//             } else {
//               ct.randomIndex.value++;
//             }
//             resetCountDown();
//             timer?.cancel();
//           });
//         }
//       });
//   }
//
//   @override
//   void onClose() {
//     videoPlayerController.dispose();
//     timer?.cancel();
//     timerCountDown?.cancel();
//     super.onClose();
//   }
// }
//
// //---------------------------------------------
