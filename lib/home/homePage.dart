//首页

import 'package:dibbler_android/video/videoNewPage.dart';
import 'package:dibbler_android/view/scrollingText.dart';
import 'package:dibbler_android/video/videoPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../video/VideoNewController.dart';
import '../video/videoFullScreen.dart';
import 'homeController.dart';
import '../view/mycustomclipper.dart';
import '../video/videoController.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController ct = Get.put(HomeController());

  final ScrollingTextController sc = Get.put(ScrollingTextController());
  double smallVideoWidth = 194.w;
  double smallVideoHeight = 109.h;

  //增加范围
  double addScope = 20.w;

  @override
  void initState() {
    super.initState();
  }

  //6个图片
  Widget sixImageWidget(int index) {
    return ClipPath(
        clipper: MyCustomClipper(),
        child: ct.sixVideoList.length == 6
            ? SizedBox(
                width: smallVideoWidth +
                    (ct.randomIndex.value == index ? addScope : 0),
                height: smallVideoHeight +
                    (ct.randomIndex.value == index ? addScope : 0),
                child: ct.randomIndex.value == index
                    ? Image.network(
                        ct.sixVideoList[index].cover,
                        fit: BoxFit.cover,
                      )
                    : ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5), // 指定颜色和透明度
                          BlendMode.srcOver, // 选择混合模式，可以根据需要调整
                        ),
                        child: Image.network(
                          ct.sixVideoList[index].cover,
                          fit: BoxFit.cover,
                        ),
                      ),
              )
            : Container(
                width: smallVideoWidth,
                height: smallVideoHeight,
                color: Colors.black,
                child: const Center(
                    child: Text(
                  '加载中',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )),
              ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 31, 56, 1),
      body: Stack(
        children: [
          //背景
          Positioned.fill(child: Image.asset('assets/images/bg.png')),
          ////标题
          Positioned(
              top: 369.5.h,
              left: 0.w,
              right: 0.w,
              child: Center(
                child: Text(
                  '本节目由 “微信名称微信名称”点播',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),

          //视频
          Obx(() => Positioned(
                left: 366.5.w,
                right: 366.5.w,
                top: 524.5.h,
                bottom: 559.5.h,
                child: Hero(
                  tag: 'video',
                  createRectTween: (begin, end) {
                    return RectTween(begin: begin, end: end);
                  },
                  child: ClipPath(
                      clipper: MyCustomClipper(isRadius: false),
                      child: ct.sixVideoList.length == 6
                          ? const VideoPage()
                          : Container(
                              color: Colors.black,
                              child: const Center(
                                child: Text(
                                  '加载中',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )),
                ),
              )),

          //上方时间
          Obx(
            () => Positioned(
              top: 25.h,
              right: 0.w,
              left: 0.w,
              height: 265.h,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ct.time.value,
                      style: TextStyle(
                        color: const Color.fromRGBO(101, 194, 255, 1),
                        fontSize: 70.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${ct.weekDay.value} | ${ct.date.value}',
                      style: TextStyle(
                        color: const Color.fromRGBO(101, 194, 255, 1),
                        fontSize: 25.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //图片组 0
          Obx(() {
            return Positioned(
                left: 150.w - (ct.randomIndex.value == 0 ? addScope : 0),
                top: 556.5.h - (ct.randomIndex.value == 0 ? addScope : 0),
                child: sixImageWidget(0));
          }),

          //1
          Obx(
            () => Positioned(
                left: 120.w - (ct.randomIndex.value == 1 ? addScope : 0),
                top: 711.h - (ct.randomIndex.value == 1 ? addScope : 0),
                child: sixImageWidget(1)),
          ),

          //2
          Obx(
            () => Positioned(
                left: 150.w - (ct.randomIndex.value == 2 ? addScope : 0),
                top: 865.5.h - (ct.randomIndex.value == 2 ? addScope : 0),
                child: sixImageWidget(2)),
          ),

          //3
          Obx(
            () => Positioned(
                right: 150.w - (ct.randomIndex.value == 3 ? addScope : 0),
                top: 556.5.h - (ct.randomIndex.value == 3 ? addScope : 0),
                child: sixImageWidget(3)),
          ),

          //4
          Obx(
            () => Positioned(
                right: 120.w - (ct.randomIndex.value == 4 ? addScope : 0),
                top: 711.h - (ct.randomIndex.value == 4 ? addScope : 0),
                child: sixImageWidget(4)),
          ),

          //5
          Obx(
            () => Positioned(
                right: 150.w - (ct.randomIndex.value == 5 ? addScope : 0),
                top: 865.5.h - (ct.randomIndex.value == 5 ? addScope : 0),
                child: sixImageWidget(5)),
          ),

          //简介
          Obx(
            () => Positioned(
                left: 415.w,
                right: 415.w,
                top: 992.h,
                child: SizedBox(
                    child: Text(
                  ct.sixVideoList.length == 6
                      ? ct.sixVideoList[ct.randomIndex.value].introduction
                      : "",
                  style: TextStyle(
                    color: const Color.fromRGBO(101, 194, 255, 1),
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 3,
                ))),
          ),

          //下方扫码
          Positioned(
              bottom: 20.h,
              left: 0.w,
              right: 0.w,
              child: SizedBox(
                height: 265.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '扫码下发二维码点播',
                      style: TextStyle(
                        color: const Color.fromRGBO(101, 194, 255, 1),
                        fontSize: 48.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Image.asset(
                      'assets/images/below.png',
                      width: 35.5.w,
                      height: 48.h,
                    ),
                  ],
                ),
              )),

          //最底部滚动文字 滚动3次
          Obx(() {
            return ScrollingText(
              text: sc.text.value,
              textStyle: TextStyle(color: Colors.white, fontSize: 50.sp),
              scrollDuration: Duration(seconds: 8),
              stopDuration: Duration(seconds: 1),
              maxScrolls: 3,
            );
          }),

          //测试
          Positioned(
            left: 300.w,
            bottom: 300.h,
            child: ElevatedButton(
                onPressed: () {
                  ct.isAutoPlay.value = false;
                  Get.to(() => const VideoFullScreen());
                },
                child: Text('测试')),
          )
        ],
      ),
    );
  }
}
