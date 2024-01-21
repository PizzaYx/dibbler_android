import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class MyCustomClipper extends CustomClipper<Path> {
  late double radius;

  //true 为2.w false 6.w
  MyCustomClipper({ bool isRadius = true}) : super() {
    if (isRadius == true) {
      radius = 2.w;
    } else {
      radius = 6.w;
    }
  }

  Path getPathWithBorder(Size size) {
    final path = getClip(size);

    // 创建一个边框
    final borderPath = Path();

    // 可以根据需要调整边框的宽度
    double borderWidth = 5.0;

    // 获得边框的路径，相当于将原路径放大 borderWidth 像素
    borderPath.addPath(
      path,
      Offset(borderWidth, borderWidth),
    );

    // 合并原路径和边框路径
    path.addPath(borderPath, Offset.zero);

    return path;
  }


  @override
  Path getClip(Size size) {
    // final paint = Paint()..color = Colors.blue;
    final path = Path();

    //减少的宽
    var reduceWidth = (size.width * 0.15).w;
    double radius = this.radius;

    path.moveTo(reduceWidth + radius, 0);

    path.lineTo(size.width - reduceWidth - radius, 0);

    //右上角
    path.quadraticBezierTo(size.width - reduceWidth, 0,
        size.width - reduceWidth + radius, radius);

    //右角
    path.lineTo(size.width - radius, size.height / 2 - radius * 2);
    path.quadraticBezierTo(size.width, size.height / 2, size.width - radius,
        size.height / 2 + radius * 2);

    //右下角
    path.lineTo(size.width - reduceWidth + radius, size.height - radius);
    path.quadraticBezierTo(size.width - reduceWidth, size.height,
        size.width - reduceWidth - radius, size.height);

    //左下角
    path.lineTo(reduceWidth + radius, size.height);
    path.quadraticBezierTo(
        reduceWidth, size.height, reduceWidth - radius, size.height - radius);

    //左角
    path.lineTo(radius, size.height / 2 + radius * 2);
    path.quadraticBezierTo(
        0, size.height / 2, radius, size.height / 2 - radius * 2);

    path.lineTo(reduceWidth - radius, radius);
    path.quadraticBezierTo(reduceWidth, 0, reduceWidth + radius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}


class MyCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 在这里获取带有边框的路径并绘制
    Path pathWithBorder = MyCustomClipper().getPathWithBorder(size);

    // 使用带有边框的路径进行绘制
    Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(pathWithBorder, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}