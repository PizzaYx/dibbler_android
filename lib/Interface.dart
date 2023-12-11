import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dibbler_android/sqlStore.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'entities.dart';
import 'homeController.dart';

//域名头
String baseUrl = "http://192.168.0.148:8090/clientport/";
final HomeController ct = Get.find<HomeController>();


String deviceId = '';
Future<void> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    deviceId = androidInfo.id;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    deviceId = iosInfo.identifierForVendor!;
  }
  getDownloadVideoList();
}

Future<void> getDownloadVideoList() async {
  List<DownloadMovie> movies = [];
  try {
    var response = await Dio().get("${baseUrl}getDownloadVideoList?clientId=$deviceId");
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

Future<void> updateVideoIsDownload(String movieId) async {
  try {
    var response =
        await Dio().get("${baseUrl}updateVideoIsDownload?id=$movieId?clientId=$deviceId");
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
