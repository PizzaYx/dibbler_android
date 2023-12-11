import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dibbler_android/sqlStore.dart';
import 'package:get/get.dart';
import 'Interface.dart';
import 'downLoadStore.dart';
import 'entities.dart';
import 'video_view.dart';

//测试数据
List<String> movieCovers = [
  'https://img.zcool.cn/community/0198425d33fa68a80120695c145f04.jpg@1280w_1l_2o_100sh.jpg',
  'https://img.zcool.cn/community/0130215bf57cb3a80121ab5db623c5.jpg@1280w_1l_2o_100sh.jpg',
  'https://tse3-mm.cn.bing.net/th/id/OIP-C.BgnDJDbZpCZEn_kNffv8QgHaKd?rs=1&pid=ImgDetMain',
  'https://pic.ntimg.cn/file/20211105/10500364_101835253103_2.jpg',
  'https://pic.ntimg.cn/file/20211213/24787180_221806192127_2.jpg',
  'https://puui.qpic.cn/vcover_vt_pic/0/21lkd9oax1s2slit1463754775.jpg/0',
  // 添加更多电影封面图链接
];

class HomeController extends GetxController {
  //当前页面状态  false 默认显示图片 true.播放视频
  var isPlayState = false.obs;

  //是否可以下载状态
  var isDownload = false.obs;

  //设备唯一标识
  late final String deviceId;

  @override
  void onInit() {
    updateTime();

    final VideoController vct = Get.put(VideoController());
    vct.setAutoPlayUrlTitle();
    //延迟5s isPlayState改为true
    Future.delayed(const Duration(seconds: 10), () {
      getDeviceId();
      //初始获取一次 随机播放的视频
      final VideoController vct = Get.put(VideoController());
      vct.setAutoPlayUrlTitle();
      //测试10S后显示视频
      isPlayState.value = true;
    });

    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // 先存储在sql中
  Future<void> handlingLinks(List<DownloadMovie> movies) async {
    //遍历movies
    for (int i = 0; i < movies.length; i++) {
      //如果数据库中没有该电影
      bool isExist = await SqlStore.to.queryDownload(movies[i].movieId);
      if (isExist == false) {
        //插入数据库
        SqlStore.to.insertDownload(movies[i].movieId, movies[i].url,
            movies[i].cover, movies[i].title, "null", '', movies[i].synchro);
      }
    }

    //下载新电影 并且查找表中所有电影的状态不为succeeded的电影
    List<Map<String, Object?>> resultSet =
        await SqlStore.to.queryAllDownloadNotSucceeded();
    if (resultSet.isNotEmpty) {
      //将resultSet转换为DownloadMovie 不要localPath synchro字段
      List<DownloadMovie> needDownloadMovies = [];
      for (int i = 0; i < resultSet.length; i++) {
        DownloadMovie movie = DownloadMovie(
          resultSet[i]['movieId'] as String,
          resultSet[i]['url'] as String,
          resultSet[i]['cover'] as String,
          resultSet[i]['title'] as String,
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
    } else {
      Get.snackbar('提示', '没有需要下载的电影');
    }
  }

  //---------时间管理---------------
  //星期几
  var weekDay = ''.obs;

  //年月日
  var date = ''.obs;

  //时间
  var time = ''.obs;

  //使用定时器更新时间 并赋值给变量
  void updateTime() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();
      List<String> weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
      weekDay.value = weekdays[now.weekday - 1];
      date.value = '${now.year}-${now.month}-${now.day}';
      //判断需要补0 24小时制
      String hour = now.hour < 10 ? '0${now.hour}' : '${now.hour}';
      String minute = now.minute < 10 ? '0${now.minute}' : '${now.minute}';
      time.value = '$hour : $minute';
    });
  }

//--------------视频-----------------

//-----------------------------------
}
