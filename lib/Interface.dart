import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dibbler_android/sqlStore.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'entities.dart';
import 'homeController.dart';

//域名头
String baseUrl = "http://192.168.0.148:8090/clientport/";
final HomeController ct = Get.find<HomeController>();

//设置SQL存储路径
Future<String> getLocalSQLlPath() async {
  await Permission.storage.request().isGranted;
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  String sqlPath = '';
  sqlPath = prefs.getString('localPath') ?? '';

  if (sqlPath != "") {
    return sqlPath;
  } else {
    String path = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    // Obtain shared preferences.
    createFolder('$path/dib/');
    sqlPath = '$path/dib/';
    prefs.setString('localSQLPath', sqlPath);
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

//获取视频列表
Future<void> getDownloadVideoList() async {
  List<DownloadMovie> movies = [];
  try {
    var response = await Dio()
        .get("${baseUrl}getDownloadVideoList?clientId=${getDeviceId()}");
    print(response.data);
    if (response.data['code'] == 200) {
      List<dynamic> data = response.data['data'];
      for (int i = 0; i < data.length; i++) {
        movies.add(DownloadMovie.fromJson(data[i]));
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
    var response = await Dio().get(
        "${baseUrl}updateVideoIsDownload?id=$movieId&clientId=${getDeviceId()}");
    print(response.data);
    if (response.data['code'] == 200) {
      // Get.snackbar('提示', '更新成功');
      //更新数据库
      SqlStore.to.updateSynchro(movieId, -1);
      //随机获取
      ct.getRandomDownloadMovie();
    }
  } catch (e) {
    print(e);
  }
}

//GETgetVideoPlayList
Future<void> getVideoPlayList() async {
  List<PlayVideo> movies = [];
  try {
    var response =
        await Dio().get("${baseUrl}getVideoPlayList?clientId=${getDeviceId()}");

    if (response.data['code'] == 200) {
      List<dynamic> data = response.data['data'];

      for (int i = 0; i < data.length; i++) {
        movies.add(PlayVideo.fromJson(data[i]));
      }

        ct.setPlayList(movies);

    }
  } catch (e) {
    print(e);
  }
}

//GET /clientport/delVideoPlayList 移除播放视频
Future<void> delVideoPlayList(String id) async {
  try {
    var response = await Dio().get("${baseUrl}delVideoPlayList?id=$id");
    if (response.data['code'] == 200) {
      getVideoPlayList();
    }
  } catch (e) {
    print(e);
  }
}
