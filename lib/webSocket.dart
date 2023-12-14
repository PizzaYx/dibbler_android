import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';

import 'Interface.dart';

class WebSocketController extends GetxController {
  late IOWebSocketChannel channel;
  var message = ''.obs;
  late Timer _timer;

  @override
  void onInit() {
    super.onInit();
  }

  void startStream() {
    channel = IOWebSocketChannel.connect(
        'ws://192.168.0.148:8090/websocket/$getDeviceId()');
    channel.stream.listen((event) {
      //解析{"data":"添加视频成功","type":"video"}获取出type和data的值
      var json = jsonDecode(event);
      String type = json['type'];
      String data = json['data'];
      if (type == 'video') {
        //如果是video类型，就获取视频列表
        getDownloadVideoList();
      } else if (type == "pay") {
       //获取播放视频
        getVideoPlayList();
      }

      print('接收消息-------$event');
    }, onError: (error) {
      // 延迟 10s后重新连接
      print('接收消息错误-------$error');
      Timer(const Duration(seconds: 10), () {
        channel.sink.close();
        startStream();
      });
    }, onDone: () {
      print('接收消息完成-------');
      // Timer(const Duration(seconds: 10), () {
      //   startStream();
      // });
    });
  }

  void sendMessage(String text) {
    if (text.isNotEmpty) {
      channel.sink.add(text);
    }
  }

  void startHeartbeat() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      channel.sink.add('heartbeat');
    });
  }

  void stopHeartbeat() {
    _timer.cancel();
  }

  void close() {
    stopHeartbeat();
    channel.sink.close();
  }

  @override
  void onClose() {
    channel.sink.close();
    super.onClose();
  }
}
