import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScrollingTextController extends GetxController {
  var text = ''.obs;

  void changeText(String newText) {
    text.value = newText;
  }
}

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final Duration scrollDuration;
  final Duration stopDuration;
  final int maxScrolls;

  const ScrollingText({
    super.key,
    required this.text,
    required this.textStyle,
    required this.scrollDuration,
    required this.stopDuration,
    required this.maxScrolls,
  });

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _scrollCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.scrollDuration,
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _scrollCount++;
          if (_scrollCount < widget.maxScrolls) {
            Future.delayed(widget.stopDuration).then((_) {
              if (mounted) {
                _controller.reset();
                _controller.forward();
              }
            });
          }
        }
      });
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ScrollingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _controller.reset();
      _controller.forward();
      _scrollCount = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        //计算文本宽度
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.textStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final double textWidth = textPainter.size.width;

        return Positioned(
          bottom: 0,
          right:_controller.value * (MediaQuery.of(context).size.width + textWidth) - textWidth, // 使用 Positioned 来控制文本的位置
          child: child!,
        );
      },
      child: Text(
        widget.text,
        style: widget.textStyle,
      ),
    );
  }
}
