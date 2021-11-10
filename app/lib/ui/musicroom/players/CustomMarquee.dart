import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class CustomMarquee extends StatelessWidget {
  CustomMarquee({
    Key key,
    @required this.text,
    @required this.fontStyle,
    this.fontWeight = FontWeight.w600,
    this.velocity = 30.0,
    this.blankSpace = 65.0,
    this.startAfter = const Duration(milliseconds: 2000),
    this.pauseAfterRound = const Duration(milliseconds: 2000),
  }) : super(key: key);

  String text;
  final TextStyle fontStyle;
  final FontWeight fontWeight;
  final double velocity;
  final double blankSpace;
  final Duration startAfter;
  final Duration pauseAfterRound;

  @override
  Widget build(BuildContext context) {
    if (text == null) text = '';
    return SizedBox(
      height:
          (fontStyle.fontSize + 6.0) * MediaQuery.of(context).textScaleFactor,
      child: AutoSizeText(
        text,
        minFontSize: fontStyle.fontSize,
        maxFontSize: fontStyle.fontSize,
        style: fontStyle,
        overflowReplacement: Marquee(
          text: text,
          blankSpace: blankSpace,
          accelerationCurve: Curves.easeOutCubic,
          velocity: velocity,
          startPadding: 2.0,
          startAfter: startAfter,
          pauseAfterRound: pauseAfterRound,
          style: fontStyle,
        ),
      ),
    );
  }
}
