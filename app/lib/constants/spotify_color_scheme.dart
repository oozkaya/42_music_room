import 'package:flutter/material.dart';

class SpotifyColors {
  static const Color green = const Color(0xff1DB954);
  static const Color black = const Color(0xff121212);
  static const Color darkGray = const Color(0xff212121);
  static const Color mediumGray = const Color(0xff535353);
  static const Color lightGray = const Color(0xffb3b3b3);
  static const Color cream = const Color(0xffedf0ed);
}

extension SpotifyColorScheme on ColorScheme {
  Color get green => SpotifyColors.green;
  Color get black => SpotifyColors.black;
  Color get darkGray => SpotifyColors.darkGray;
  Color get mediumGray => SpotifyColors.mediumGray;
  Color get lightGray => SpotifyColors.lightGray;
  Color get cream => SpotifyColors.cream;
}
