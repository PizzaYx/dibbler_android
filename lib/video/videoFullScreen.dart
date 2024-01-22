//全屏视频
import 'package:dibbler_android/video/videoNewPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../home/homeController.dart';

class VideoFullScreen extends StatefulWidget {
  const VideoFullScreen({super.key});

  @override
  State<VideoFullScreen> createState() => _VideoFullScreenState();
}

class _VideoFullScreenState extends State<VideoFullScreen> {
  final HomeController ct = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if(ct.isAutoPlay.value == true){
        Get.back();
      }
      return Scaffold(
        body: SizedBox(
          width: Get.width,
          height: Get.height,
          child: Stack(
            children: [
              const Positioned(
                child: Hero(
                  tag: 'video',
                  child: VideoPage(),
                ),
              ),
              Positioned(
                top: 200.w,
                left: 200.w,
                child: IconButton(
                  icon: const Icon(
                    Icons.add,
                    size: 200,
                  ),
                  onPressed: () {
                    ct.isAutoPlay.value = true;
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
