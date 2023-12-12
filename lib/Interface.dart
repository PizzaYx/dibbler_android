import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dibbler_android/sqlStore.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'entities.dart';
import 'homeController.dart';

//域名头
String baseUrl = "http://192.168.0.148:8090/clientport/";
final HomeController ct = Get.find<HomeController>();

String thisDeviceId = "";
//存储sql路径
String localSQLPath = "";
//存储视频路径
String localVideoPath = "";

//设置存储路径
Future<String> getLocalPath() async {
  await Permission.storage.request().isGranted;
  String path = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_PICTURES);

  createFolder('$path/dib/');
  localSQLPath = '$path/dib/';

  createFolder('$path/video/');
  localVideoPath = '$path/video/';

  return localSQLPath;
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
Future<void> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    thisDeviceId = androidInfo.id;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    thisDeviceId = iosInfo.identifierForVendor!;
  }
}

//获取视频列表
Future<void> getDownloadVideoList() async {
  List<DownloadMovie> movies = [];
  try {
    var response = await Dio()
        .get("${baseUrl}getDownloadVideoList?clientId=$thisDeviceId");
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
        "${baseUrl}updateVideoIsDownload?id=$movieId?clientId=$thisDeviceId");
    print(response.data);
    if (response.data['code'] == 200) {
      Get.snackbar('提示', '更新成功');
      //更新数据库
      SqlStore.to.updateSynchro(movieId, -1);
    }
  } catch (e) {
    print(e);
  }
}
