//首页
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
          Positioned(
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
          ),
          //左侧视频
          Positioned(
            left: 95.5.w,
            top: 77.h,
            child: SizedBox(
              width: 515.w,
              height: 290.h,
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
          ),

          //右侧 3个竖向排列 文本按钮
          Positioned(
            right: 30.w,
            top: 57.h,
            bottom: 50,
            child:Column(
              children: [
                //文本按钮
                TextButton(
                  onPressed: () {
                    ct.isPlayState.value = !ct.isPlayState.value;
                  },
                  child: Text(
                    '播放随机视频',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    getDownloadVideoList();
                  },
                  child: Text(
                    '下载播放列表',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    vct.changeVideo(
                        'https://www.runoob.com/try/demo_source/movie.mp4',
                        '视频标题');
                  },
                  child: Text(
                    '播放指定视频',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            )
          ),

          //底部电影封面列表 使用插件infinite_carousel
          Positioned(
            bottom: 30.h,
            left: 0,
            right: 0,
            child: CarouselSlider(
              items: movieCovers.map((imageUrl) {
                return Transform.translate(
                  offset: Offset(-105.w, 0),
                  //在图片上层叠图片的标题
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 15.w),
                        child: Image.network(
                          imageUrl,
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
                          '电影标题',
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
          )
        ],
      ),
    );
  }
}
