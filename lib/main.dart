import 'package:dibbler_android/tools/downLoadStore.dart';
import 'package:dibbler_android/video/VideoNewController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'home/homePage.dart';
import 'tools/sqlStore.dart';
import 'video/videoController.dart';
import 'tools/webSocket.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 隐藏状态栏
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  // 设置设备方向
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //SQL
    Get.put<SqlStore>(SqlStore());
    //下载
    Get.put<DownLoadStore>(DownLoadStore());
    // //视频
    // Get.put<VideoController>(VideoController());
    //websocket
    Get.put<WebSocketController>(WebSocketController());

    //初始化

    //初始化下载
    return  ClipOval(
      child: ScreenUtilInit(
        designSize:  const Size(1533, 1533),
        minTextAdapt: false,
        splitScreenMode: false,
        builder: (context, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: '点播器',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home:  const HomePage(),
          );
        },
      ),
    );
  }
}
