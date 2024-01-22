import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dibbler_android/tools/sqlStore.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities.dart';
import '../home/homeController.dart';
import 'package:path_provider/path_provider.dart';

import '../video/VideoNewController.dart';

//域名头
String baseUrl = "http://192.168.0.148:8090/clientport/";
final HomeController ct = Get.find<HomeController>();

//设置SQL存储路径
Future<String> getLocalSQLlPath() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  String sqlPath = '';
  sqlPath = prefs.getString('localPath') ?? '';

  if (sqlPath != "") {
    return sqlPath;
  } else {
    String path = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_MOVIES);
    // Directory? directory = await getExternalStorageDirectory();
    // String path = directory!.path;
    // Obtain shared preferences.
    //下载视频存放
    createFolder('$path/dib/');
    //sql
    createFolder('$path/dib/sql/');
    sqlPath = '$path/dib/';
    prefs.setString('localPath', sqlPath);
    return sqlPath;
  }
}

//创建文件夹
Future<void> createFolder(String newFolderPath) async {
  // 创建文件夹
  Directory newFolder = Directory(newFolderPath);
  bool folderExists = await newFolder.exists();

  if (!folderExists) {
    // 文件夹不存在时才创建
    await newFolder.create(recursive: true);
    print('文件夹已创建：$newFolderPath');
  } else {
    print('文件夹已存在：$newFolderPath');
  }
}

//获取设备唯一标识
Future<String> getDeviceId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String id = prefs.getString('thisDeviceId') ?? '';

  if (id != "") {
    return id;
  } else {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      id = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      id = iosInfo.identifierForVendor!;
    }

    prefs.setString('thisDeviceId', id);
    return id;
  }
}

//获取下载视频列表
Future<void> getDownloadVideoList() async {
  List<MovieData> movies = [];
  try {
    String deviceId = await getDeviceId();
    var response =
        await Dio().get("${baseUrl}getDownloadVideoList?clientId=$deviceId");
    debugPrint(response.data.toString());
    if (response.data['code'] == 200) {
      List<dynamic> data = response.data['data'];
      for (int i = 0; i < data.length; i++) {
        movies.add(MovieData.fromJson(data[i]));
      }
      if (movies.isNotEmpty) {
        ct.handlingLinks(movies);
      }
    }
  } catch (e) {
    print(e);
  }
}

//更新视频下载状态
Future<void> updateVideoIsDownload(String movieId) async {
  try {
    String deviceId = await getDeviceId();
    var response = await Dio()
        .get("${baseUrl}updateVideoIsDownload?id=$movieId&clientId=$deviceId");
    print(response.data);
    if (response.data['code'] == 200) {
      //更新数据库
      SqlStore.to.updateSynchro(movieId, -1);
    }
  } catch (e) {
    print(e);
  }
}

//GETgetVideoPlayList 获取订单播放视频列表
Future<void> getVideoPlayList() async {
  List<PlayVideo> movies = [];
  // 模拟服务器响应数据
  String mockResponse = '''
{
  "code": 200,
  "msg": "操作成功",
  "data": [
   
  ]
}
''';

//   {
//     "id": "0dbd88f8ad0e4d82a95d60310bf70936",
//   "orderId": "ZB23120887e13fe94fb22222",
//   "delFlag": null,
//   "createTime": 1703127338000,
//   "videoId": "b1f385ee4fae4374a2e0554cafc3301b",
//   "title": "光进来的地方——女性文学修养和创作",
//   "nickname": "张三",
//   "truename": "张三"
// }
  // 解析模拟响应数据
  Map<String, dynamic> mockData = json.decode(mockResponse);

// 处理模拟数据
  if (mockData['code'] == 200) {
    List<dynamic> data = mockData['data'];
    List<PlayVideo> movies = [];
    for (int i = 0; i < data.length; i++) {
      movies.add(PlayVideo.fromJson(data[i]));
    }
    ct.payVideo.value = movies;
  } else {
    ct.payVideo.value = [];
  }
  if(ct.payVideo.isNotEmpty){
    VideoController.instance.payVideoLogic();
  }


}

// try {
//   String deviceId = await getDeviceId();
//   var response =
//       await Dio().get("${baseUrl}getVideoPlayList?clientId=$deviceId");
//   if (response.data['code'] == 200) {
//     List<dynamic> data = response.data['data'];
//     String moveString = '';
//     for (int i = 0; i < data.length; i++) {
//       movies.add(PlayVideo.fromJson(data[i]));
//     }
//     ct.payVideo.value = movies;
//   } else {
//     ct.payVideo.value = [];
//   }
//   ct.payVideoLogic();
// } catch (e) {
//   print('获取订单播放视频错误');
// }
//}

//GET /clientport/delVideoPlayList 移除播放视频
Future<void> delVideoPlayList(String id) async {
  try {
    var response = await Dio().get("${baseUrl}delVideoPlayList?id=$id");
    if (response.data['code'] == 200) {
      print("移除成功");
    }
  } catch (e) {
    print(e);
  }
}
