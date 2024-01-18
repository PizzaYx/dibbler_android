//首页
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dibbler_android/scrollingText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'homeController.dart';
import 'mycustomclipper.dart';
import 'video_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController ct = Get.put(HomeController());
  final VideoController vct = Get.find<VideoController>();
  final ScrollingTextController sc = Get.put(ScrollingTextController());
  double smallVideoWidth = 194.w;
  double smallVideoHeight = 109.h;

  //增加范围
  double addScope = 10.w;

  @override
  void initState() {
    super.initState();
  }

  //6个图片
  Widget sixImageWidget(int index) {
    return ClipPath(
        clipper: MyCustomClipper(),
        child: ct.sixVideoList.isEmpty
            ? Container(
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
              )
            : SizedBox(
                width: smallVideoWidth +
                    (ct.randomIndex.value == 0 ? 0 : addScope),
                height: smallVideoHeight +
                    (ct.randomIndex.value == 0 ? 0 : addScope),
                child: Image.network(
                  ct.sixVideoList[index].cover,
                  fit: BoxFit.cover,
                ),
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
          Positioned(
            left: 366.5.w,
            right: 366.5.w,
            top: 524.5.h,
            bottom: 559.5.h,
            child: ClipPath(
                clipper: MyCustomClipper(isRadius: false),
                child: VideoPlayerWidget()),
          ),

          //图片组 0
          Obx(() {
            return Positioned(
                left: 150.w - (ct.randomIndex.value == 0 ? 0 : addScope),
                top: 556.5.h - (ct.randomIndex.value == 0 ? 0 : addScope),
                child: sixImageWidget(0));
          }),

          //1
          Obx(
            () => Positioned(
                left: 120.w - (ct.randomIndex.value == 0 ? 0 : addScope),
                top: 711.h - (ct.randomIndex.value == 0 ? 0 : addScope),
                child: sixImageWidget(1)),
          ),

          //2
          Obx(
            () => Positioned(
                left: 150.w - (ct.randomIndex.value == 0 ? 0 : addScope),
                top: 865.5.h - (ct.randomIndex.value == 0 ? 0 : addScope),
                child: sixImageWidget(2)),
          ),

          //3
          Obx(
            () => Positioned(
                right: 150.w - (ct.randomIndex.value == 0 ? 0 : addScope),
                top: 556.5.h - (ct.randomIndex.value == 0 ? 0 : addScope),
                child: sixImageWidget(3)),
          ),

          //4
          Obx(
            () => Positioned(
                right: 120.w - (ct.randomIndex.value == 0 ? 0 : addScope),
                top: 711.h - (ct.randomIndex.value == 0 ? 0 : addScope),
                child: sixImageWidget(4)),
          ),

          //5
          Obx(
            () => Positioned(
                right: 150.w - (ct.randomIndex.value == 0 ? 0 : addScope),
                top: 865.5.h - (ct.randomIndex.value == 0 ? 0 : addScope),
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
                  ct.sixVideoList.isEmpty
                      ? ""
                      : ct.sixVideoList[ct.randomIndex.value].introduction,
                  style: TextStyle(
                    color: const Color.fromRGBO(101, 194, 255, 1),
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 3,
                ),
              ),
            ),
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

          //顶部标题 高60 顶部标题 右侧显示 星期 年月日 时分
          // Obx(
          //   () => vct.isAutoPlay.value == true
          //       ? Positioned(
          //           top: 0,
          //           left: 0,
          //           right: 0,
          //           height: ,
          //           child: Container(
          //             height: 57.h,
          //             width: double.infinity,
          //             color: const Color.fromRGBO(35, 46, 102, 0.4),
          //             padding: EdgeInsets.only(left: 30.w, right: 30.w),
          //             child: Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               crossAxisAlignment: CrossAxisAlignment.center,
          //               children: [
          //                 Text(
          //                   'xxxxxxxxxxxx视频观看系统',
          //                   style: TextStyle(
          //                     color: Colors.white,
          //                     fontSize: 20.sp,
          //                   ),
          //                 ),
          //                 Obx(() {
          //                   return Row(
          //                     children: [
          //                       Column(
          //                         mainAxisAlignment: MainAxisAlignment.center,
          //                         children: [
          //                           Text(
          //                             ct.weekDay.value,
          //                             style: TextStyle(
          //                               color: Colors.white,
          //                               fontSize: 8.sp,
          //                             ),
          //                           ),
          //                           Text(
          //                             ct.date.value,
          //                             style: TextStyle(
          //                               color: Colors.white,
          //                               fontSize: 8.sp,
          //                             ),
          //                           ),
          //                         ],
          //                         //时分
          //                       ),
          //                       const SizedBox(
          //                         width: 5,
          //                       ),
          //                       //时 分
          //                       Text(
          //                         ct.time.value,
          //                         style: TextStyle(
          //                           color: Colors.white,
          //                           fontSize: 25.sp,
          //                           //加粗
          //                           fontWeight: FontWeight.bold,
          //                         ),
          //                       ),
          //                     ],
          //                   );
          //                 }),
          //               ],
          //             ),
          //           ),
          //         )
          //       : Container(),
          // ),
          //中间视频
          // Obx(() => Positioned(
          //       left: vct.isAutoPlay.value == true ? 95.5.w : 0,
          //       top: vct.isAutoPlay.value == true ? 77.h : 0,
          //       child: Container(
          //         width: vct.isAutoPlay.value == true ? 515.w : Get.width,
          //         height: vct.isAutoPlay.value == true ? 290.h : Get.height,
          //         //根据isPlayState状态判断显示图片还是视频
          //         child: Obx(() {
          //           if (ct.isPlayState.value == false) {
          //             return Image.asset(
          //               'assets/images/defultImg.jpg',
          //               width: 515.w,
          //               height: 290.h,
          //               fit: BoxFit.cover,
          //             );
          //           } else {
          //             return const VideoPlayerWidget();
          //           }
          //         }),
          //       ),
          //     )),

          //底部电影封面列表 使用插件infinite_carousel
          // Obx(() => vct.isAutoPlay.value == true
          //     ? Obx(() => Positioned(
          //           bottom: 30.h,
          //           left: 0,
          //           right: 0,
          //           child: CarouselSlider(
          //             items: ct.allVideoList.map((data) {
          //               return Transform.translate(
          //                 offset: Offset(-105.w, 0),
          //                 //在图片上层叠图片的标题
          //                 child: Stack(
          //                   children: [
          //                     Container(
          //                       padding: EdgeInsets.only(right: 15.w),
          //                       child: Image.network(
          //                         data.cover,
          //                         fit: BoxFit.cover,
          //                         width: 227.5.w,
          //                         height: 128.h,
          //                       ),
          //                     ),
          //                     Positioned(
          //                       bottom: 0,
          //                       left: 0,
          //                       right: 0,
          //                       child: Container(
          //                         height: 34.h,
          //                         decoration: BoxDecoration(
          //                           gradient: LinearGradient(
          //                             begin: Alignment.topCenter,
          //                             end: Alignment.bottomCenter,
          //                             colors: [
          //                               Colors.black.withOpacity(0.0),
          //                               Colors.black.withOpacity(1),
          //                             ],
          //                           ),
          //                         ),
          //                       ),
          //                     ),
          //                     Positioned(
          //                       bottom: 7.h,
          //                       left: 8.w,
          //                       child: Text(
          //                         data.title,
          //                         style: TextStyle(
          //                           color: Colors.white,
          //                           fontSize: 10.sp,
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               );
          //             }).toList(),
          //             options: CarouselOptions(
          //               aspectRatio: 16 / 9,
          //               height: 128.h,
          //               autoPlay: true,
          //               viewportFraction: 0.25,
          //             ),
          //           ),
          //         ))
          //     : Container()),
          //最底部滚动文字 滚动3次
          // Positioned(
          //   left: 0,
          //   right: 0,
          //   bottom: 0,
          //   child: Obx(() {
          //     return ScrollingText(
          //       text: sc.text.value,
          //       textStyle: TextStyle(color: Colors.white, fontSize: 24.sp),
          //       scrollDuration: Duration(seconds: 5),
          //       stopDuration: Duration(seconds: 1),
          //       maxScrolls: 3,
          //     );
          //   }),
          // ),
        ],
      ),
    );
  }
}
