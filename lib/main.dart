import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'downLoadStore.dart';
import 'homeController.dart';
import 'homePage.dart';
import 'sqlStore.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterDownloader.initialize(debug: true);
  // 隐藏状态栏
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  // 设置设备方向
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //SQL
    Get.put<SqlStore>(SqlStore());

    //下载
    Get.put<DownLoadStore>(DownLoadStore());
    //初始化下载
    return ScreenUtilInit(
      designSize: const Size(960, 540),
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
          home: const HomePage(),
        );
      },
    );
  }
}
