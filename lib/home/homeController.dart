import 'dart:async';
import 'package:dibbler_android/tools/sqlStore.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../tools/Interface.dart';

import '../entities.dart';
import '../tools/downLoadStore.dart';
import '../tools/webSocket.dart';
import '../video/VideoNewController.dart';
import '../video/videoFullScreen.dart';
import '../view/scrollingText.dart';

class HomeController extends GetxController {
  //设备唯一标识
  var deviceId = ''.obs;

  //视频播放管理器
  // final VideoController vct = Get.find<VideoController>();
  //websocket管理器
  final WebSocketController webSocket = Get.find<WebSocketController>();

  //页面显示6组数据
  var sixVideoList = <CoverTitle>[].obs;

  //当前播放视频下标
  var randomIndex = 0.obs;

  // 是否自动播放
  var isAutoPlay = true.obs;

  //本地数据订单视频信息
  var payVideo = <PlayVideo>[].obs;

  @override
  void onInit() async {
    //权限
    var result = await Permission.storage.request().isDenied;
    var local = await Permission.photos.request().isDenied;

    //-------逻辑顺序-------
    //打开数据库
    SqlStore.to.openDatabaseConnection();
    //时间
    updateTime();
    //获取设备唯一标识
    deviceId.value = await getDeviceId();
    //连接websocket
    webSocket.startStream();
    webSocket.startHeartbeat();

    //延迟是sql 打开或创建较慢
    //延迟20S执行一次getDownloadVideoList()方法后每隔10分钟执行一次
    Future.delayed(const Duration(seconds: 10), () async {

      getDownloadVideoList();
      //获取随机播放的视频
      querySixDownload();

      getVideoPlayList();

      //获取服务器订单视频列表
      getVideoPlayList();
    });

    //每隔10分钟获取一次视频列表 并且马上开始执行1次
    Timer.periodic(const Duration(minutes: 10), (timer) async {
      getDownloadVideoList();
      //查询下载失败的电影重新下载
      // List<String> resultSet =  await SqlStore.to.querySynchro();
      // if(resultSet.isNotEmpty){
      //   for (int i = 0; i < resultSet.length; i++) {
      //     DownLoadStore.to.setMoviesDownload(resultSet[i], 'failed');
      //   }
      // }
    });

    //------------------------
    super.onInit();
  }

  //获取数据库随机6个cover title Introduction
  Future<void> querySixDownload() async {
    //获取所有电影列表
    List<Map<String, Object?>> resultSet = await SqlStore.to.querySixDownload();
    if (resultSet.isNotEmpty) {
      sixVideoList.clear();

      for (var item in resultSet) {
        CoverTitle coverTitle = CoverTitle(
            item["cover"].toString(),
            item["title"].toString(),
            item["intro"].toString(),
            item["localPath"].toString());
        sixVideoList.add(coverTitle);
      }

      //只是在下载数据不满6组的时候才会添加
      //如果不满6组并且大于0组数据 则重复添加 总数保持6组
      if (sixVideoList.length < 6 && sixVideoList.isNotEmpty) {
        int nowLength = sixVideoList.length;
        for (int i = 0; i < 6 - nowLength; ++i) {
          sixVideoList.add(sixVideoList[i]);
        }
      }
    } else {
      print('数据库中没有电影');
    }
  }

  // 先存储在sql中
  Future<void> handlingLinks(List<MovieData> movies) async {
    //遍历movies
    for (int i = 0; i < movies.length; i++) {
      //如果数据库中没有该电影
      bool isExist = await SqlStore.to.queryDownload(movies[i].movieId);
      if (isExist == false) {
        //插入数据库
        SqlStore.to.insertDownload(
            movies[i].movieId,
            movies[i].url,
            movies[i].cover,
            movies[i].title,
            "unKnown",
            '',
            movies[i].intro,
            movies[i].synchro);
      }
    }

    //下载新电影 并且查找表中所有电影的状态不为succeeded的电影
    List<Map<String, Object?>> resultSet =
        await SqlStore.to.queryAllDownloadNotSucceeded();
    if (resultSet.isNotEmpty) {
      List<MovieData> needDownloadMovies = [];
      for (int i = 0; i < resultSet.length; i++) {
        MovieData movie = MovieData(
          resultSet[i]['movieId'] as String,
          resultSet[i]['url'] as String,
          resultSet[i]['cover'] as String,
          resultSet[i]['title'] as String,
          resultSet[i]['intro'] as String,
          resultSet[i]['synchro'] as int,
          downLoadStatus: resultSet[i]['status'] as String,
        );
        needDownloadMovies.add(movie);
      }

      //循环resultSet 传入url
      for (int i = 0; i < needDownloadMovies.length; i++) {
        DownLoadStore.to.setMoviesDownload(
            needDownloadMovies[i].url, needDownloadMovies[i].downLoadStatus);
      }
      // getAllCoverTitle();
    } else {
      print('没有需要下载的电影');
    }
  }

  //---------时间管理---------------
  //星期几
  var weekDay = ''.obs;

  //月日
  var date = ''.obs;

  //时间
  var time = ''.obs;

  //使用定时器更新时间 并赋值给变量
  void updateTime() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();
      List<String> weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
      weekDay.value = weekdays[now.weekday - 1];
      date.value = '${now.month}-${now.day}';
      //判断需要补0 24小时制
      String hour = now.hour < 10 ? '0${now.hour}' : '${now.hour}';
      String minute = now.minute < 10 ? '0${now.minute}' : '${now.minute}';
      time.value = '$hour:$minute';
    });
  }

//--------------点播视频-----------------

  //有订单数据时 处理逻辑
  void payVideoLogic() {
    VideoController vct = Get.find<VideoController>();
    //如果视频当前在播放就停止
    if (payVideo.isNotEmpty) {
      vct.stopAutoPlay();
    }
    else
      {
        isAutoPlay.value = true;
      }
  }

  // //点播播放视频列表
  //获取本地sql 订单表的1条数据
  // Future<void> getPayVideoForOne() async {
  //   List<Map<String, Object?>> resultSet = await SqlStore.to.queryOneIsPlay();
  //   List<PlayVideo> data = [];
  //   for (int i = 0; i < resultSet.length; i++) {
  //     PlayVideo movie = PlayVideo(
  //       resultSet[i]['videoId'] as String,
  //       resultSet[i]['id'] as String,
  //       resultSet[i]['title'] as String,
  //       resultSet[i]['nickname'] as String,
  //       resultSet[i]['truename'] as String,
  //       resultSet[i]['createTime'] as String,
  //       isplay: resultSet[i]['isplay'] as int,
  //     );
  //     data.add(movie);
  //   }
  //   if (data.isNotEmpty) {
  //     isAutoPlay.value = false;
  //     payVideo.value = data;
  //   } else {
  //     //--
  //     Get.to(()=>const VideoFullScreen());
  //     isAutoPlay.value = true;
  //     payVideo.value = [];
  //   }
  // }

  // //设置指定播放视频订单列表存入数据库
  // void setPlayList(List<PlayVideo> data) {
  //   for (int i = 0; i < data.length; i++) {
  //     SqlStore.to.insertOrders(
  //       data[i].id,
  //       data[i].videoId,
  //       data[i].title,
  //       data[i].nickname,
  //       data[i].truename,
  //       data[i].createTime,
  //     );
  //   }
  //   getVideoList();
  // }

  //   跑马灯数据
  void getVideoHorseList() async {
    String moveString = '';
    if (payVideo.isNotEmpty) {
      //设置跑马灯数据
      final ScrollingTextController sc = Get.find<ScrollingTextController>();
      for (int i = 0; i < payVideo.length; i++) {
        if (i == 0) {
          moveString += '当前播放: ${payVideo[i].nickname} [${payVideo[i].title}] ';
        } else {
          moveString +=
              '稍后播放: $i:${payVideo[i].nickname}[${payVideo[i].title}] ';
        }
        if (i != payVideo.length - 1) {
          moveString += "   ";
        }
      }
      sc.changeText(moveString);
    }
  }

//移除本地数据库订单列表的数据
//   void removeOrders() {
//
//
//   }

//-----------------------------------
}
