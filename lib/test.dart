// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'dart:math' as math;
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Custom Clipper Example'),
//         ),
//         body: Center(
//             child: ClipPath(
//                 clipper: MyCustomClipper(),
//                 child: Container(
//                     width: 613, height: 344, color: Colors.blue[200]))),
//       ),
//     );
//   }
// }
//
// class MyCustomClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     // final paint = Paint()..color = Colors.blue;
//     final path = Path();
//
//     //减少的宽
//     var reduceWidth = 70.0;
//     double radius = 8.0;
//
//     path.moveTo(reduceWidth + radius, 0);
//
//     path.lineTo(size.width - reduceWidth - radius, 0);
//
//     //右上角
//     path.quadraticBezierTo(size.width - reduceWidth, 0,
//         size.width - reduceWidth + radius, radius);
//
//     //右角
//     path.lineTo(size.width - radius, size.height / 2 - radius*2);
//     path.quadraticBezierTo(size.width, size.height/2, size.width-radius, size.height/2 + radius*2);
//
//     //右下角
//     path.lineTo(size.width - reduceWidth + radius, size.height - radius);
//     path.quadraticBezierTo(size.width - reduceWidth, size.height, size.width - reduceWidth-radius, size.height);
//
//     //左下角
//     path.lineTo(reduceWidth+radius, size.height);
//     path.quadraticBezierTo(reduceWidth,size.height , reduceWidth -radius, size.height - radius);
//
//     //左角
//     path.lineTo(radius, size.height/2 +radius*2);
//     path.quadraticBezierTo(0,size.height/2 , radius, size.height/2 - radius*2);
//
//     path.lineTo(reduceWidth-radius, radius);
//     path.quadraticBezierTo(reduceWidth, 0, reduceWidth + radius, 0);
//
//     path.close();
//     return path;
//   }
//
//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => true;
// }
