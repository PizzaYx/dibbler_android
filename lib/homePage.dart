//首页
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dibbler_android/scrollingText.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'Interface.dart';
import 'homeController.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(29, 31, 56, 1),
      body: Stack(
        children: [
          //顶部标题 高60 顶部标题 右侧显示 星期 年月日 时分
          Obx(
            () => vct.isAutoPlay.value == true
                ? Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 57.h,
                      width: double.infinity,
                      color: const Color.fromRGBO(35, 46, 102, 0.4),
                      padding: EdgeInsets.only(left: 30.w, right: 30.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'xxxxxxxxxxxx视频观看系统',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                            ),
                          ),
                          Obx(() {
                            return Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      ct.weekDay.value,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.sp,
                                      ),
                                    ),
                                    Text(
                                      ct.date.value,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.sp,
                                      ),
                                    ),
                                  ],
                                  //时分
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                //时 分
                                Text(
                                  ct.time.value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25.sp,
                                    //加粗
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  )
                : Container(),
          ),
          //左侧视频
          Obx(() => Positioned(
                left: vct.isAutoPlay.value == true ? 95.5.w : 0,
                top: vct.isAutoPlay.value == true ? 77.h : 0,
                child: Container(
                  width: vct.isAutoPlay.value == true ? 515.w : Get.width,
                  height: vct.isAutoPlay.value == true ? 290.h : Get.height,
                  //根据isPlayState状态判断显示图片还是视频
                  child: Obx(() {
                    if (ct.isPlayState.value == false) {
                      return Image.asset(
                        'assets/images/defultImg.jpg',
                        width: 515.w,
                        height: 290.h,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return const VideoPlayerWidget();
                    }
                  }),
                ),
              )),

          //右侧 二维码
          Obx(() => vct.isAutoPlay.value == true
              ? Positioned(
                  right: 95.5.w,
                  top: 97.h,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          //一个200*200的白色背景 圆角3
                          Container(
                            width: 200.h,
                            height: 200.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          //使用qr_flutter插件生成二维码
                          Obx(() => QrImageView(
                                data: "www.baidu.com${ct.deviceId.value}",
                                size: 200.h,
                                version: QrVersions.auto,
                              )),
                          //
                          Positioned(
                            top: 90.h,
                            left: 90.h,
                            //二维码中间放log 切圆角25
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 30.h,
                                height: 30.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      //200*40 的白色背景 圆角3 居中显示文字使用微信扫描二维码观影
                      Container(
                        width: 200.h,
                        height: 40.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '使用微信扫描二维码观影',
                          style: TextStyle(
                            color: Color.fromRGBO(0, 25, 62, 1),
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ))
              : Container()),

          //底部电影封面列表 使用插件infinite_carousel
          Obx(() => vct.isAutoPlay.value == true
              ? Obx(() => Positioned(
                    bottom: 30.h,
                    left: 0,
                    right: 0,
                    child: CarouselSlider(
                      items: ct.allVideoList.map((data) {
                        return Transform.translate(
                          offset: Offset(-105.w, 0),
                          //在图片上层叠图片的标题
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.only(right: 15.w),
                                child: Image.network(
                                  data.cover,
                                  fit: BoxFit.cover,
                                  width: 227.5.w,
                                  height: 128.h,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 34.h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.0),
                                        Colors.black.withOpacity(1),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 7.h,
                                left: 8.w,
                                child: Text(
                                  data.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      options: CarouselOptions(
                        aspectRatio: 16 / 9,
                        height: 128.h,
                        autoPlay: true,
                        viewportFraction: 0.25,
                      ),
                    ),
                  ))
              : Container()),
          //最底部滚动文字 滚动3次
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(() {
              return ScrollingText(
                text: sc.text.value,
                textStyle: TextStyle(color: Colors.white, fontSize: 24.sp),
                scrollDuration: Duration(seconds: 5),
                stopDuration: Duration(seconds: 1),
                maxScrolls: 3,
              );
            }),
          ),
        ],
      ),
    );
  }
}
