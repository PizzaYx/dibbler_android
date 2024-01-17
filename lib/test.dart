import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Custom Clipper Example'),
        ),
        body: Center(
            child: ClipPath(
                clipper: MyCustomClipper(),
                child: Container(
                    width: 613, height: 344, color: Colors.blue[200]))),
      ),
    );
  }
}

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // final paint = Paint()..color = Colors.blue;
    final path = Path();

    //减少的宽
    var reduceWidth = 70.0;
    double radius1 = 8.0, radius2 = 12;

    path.moveTo(reduceWidth + radius1, 0);

    path.lineTo(size.width - reduceWidth - radius1, 0);
    //右上角
    path.quadraticBezierTo(size.width - reduceWidth + radius1/2, 0,
        size.width - reduceWidth + radius1, radius1);

    //最右角
    path.lineTo(size.width - radius2, size.height / 2 - radius2);
    path.quadraticBezierTo(size.width-radius2/2 , size.height/2 , size.width-radius2, size.height/2 + radius2/2);

    //右下角
    path.lineTo(size.width - reduceWidth - radius1, size.height - radius1);
    //path.quadraticBezierTo(size.width - reduceWidth-radius1, size.height - radius1, size.width - reduceWidth, size.height);
    //path.quadraticBezierTo(size.width - reduceWidth, size.height,size.width - reduceWidth-radius1, size.height - radius1);
    //path.arcToPoint( Offset(600, size.height - radius1), radius: const Radius.circular(20));

    path.lineTo(reduceWidth, size.height + radius2);
    //path.quadraticBezierTo(0, size.height/2, reduceWidth, size.height/2 - radius2);
    path.lineTo(reduceWidth, radius1);
    //path.quadraticBezierTo(reduceWidth, 0, reduceWidth + radius1, 0);

    // path.moveTo(50, 0);
    // path.lineTo(size.width - 50,0);
    // path.lineTo(size.width, size.height/2);
    // path.lineTo(size.width - 50, size.height);
    // path.lineTo(50,size.height);
    // path.lineTo(0, size.height/2);
    // path.lineTo(50, 0);
    // path.close();
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
