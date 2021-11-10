import 'package:flutter/material.dart';
import './app_font_family.dart';
import './spotify_color_scheme.dart';

class AppThemes {
  AppThemes._();

  //constants color range for light theme
  static const Color _lightPrimaryColor = SpotifyColors.green;
  static const Color _lightPrimaryVariantColor = SpotifyColors.cream;
  static const Color _lightSecondaryColor = SpotifyColors.green;
  static const Color _lightOnPrimaryColor = SpotifyColors.black;
  static const Color _lightButtonPrimaryColor = SpotifyColors.green;
  static const Color _lightAppBarColor = SpotifyColors.green;
  static const Color _lightCaptionColor = SpotifyColors.mediumGray;
  static Color _lightIconColor = SpotifyColors.green;
  static Color _lightSnackBarBackgroundErrorColor = Colors.redAccent;

  //text theme for light theme
  static final TextStyle _lightScreenHeadingTextStyle =
      TextStyle(fontSize: 20.0, color: _lightOnPrimaryColor);
  static final TextStyle _lightScreenTaskNameTextStyle =
      TextStyle(fontSize: 16.0, color: _lightOnPrimaryColor);
  static final TextStyle _lightScreenTaskDurationTextStyle =
      TextStyle(fontSize: 14.0, color: Colors.grey);
  static final TextStyle _lightScreenButtonTextStyle = TextStyle(
      fontSize: 14.0, color: _lightOnPrimaryColor, fontWeight: FontWeight.w500);
  static final TextStyle _lightScreenCaptionTextStyle = TextStyle(
      fontSize: 12.0, color: _lightCaptionColor, fontWeight: FontWeight.w100);

  static final TextTheme _lightTextTheme = TextTheme(
    headline5: _lightScreenHeadingTextStyle,
    headline6: _lightScreenTaskNameTextStyle,
    bodyText1: _lightScreenTaskDurationTextStyle,
    bodyText2: _lightScreenTaskNameTextStyle,
    button: _lightScreenButtonTextStyle,
    subtitle1: _lightScreenTaskNameTextStyle,
    caption: _lightScreenCaptionTextStyle,
  );

  //constants color range for dark theme
  static const Color _darkPrimaryColor = SpotifyColors.green;
  static const Color _darkPrimaryVariantColor = SpotifyColors.black;
  static const Color _darkOnPrimaryColor = Colors.white;
  static const Color _darkSecondaryColor = SpotifyColors.lightGray;
  static const Color _darkButtonPrimaryColor = SpotifyColors.green;
  static const Color _darkAppBarColor = SpotifyColors.black;
  static const Color _darkCaptionColor = SpotifyColors.lightGray;
  static Color _darkIconColor = Colors.white;
  static Color _darkSnackBarBackgroundErrorColor = Colors.redAccent;

  //text theme for dark theme
  static final TextStyle _darkScreenHeadingTextStyle =
      _lightScreenHeadingTextStyle.copyWith(color: _darkOnPrimaryColor);
  static final TextStyle _darkScreenTaskNameTextStyle =
      _lightScreenTaskNameTextStyle.copyWith(color: _darkOnPrimaryColor);
  static final TextStyle _darkScreenTaskDurationTextStyle =
      _lightScreenTaskDurationTextStyle;
  static final TextStyle _darkScreenButtonTextStyle = TextStyle(
      fontSize: 14.0, color: _darkOnPrimaryColor, fontWeight: FontWeight.w500);
  static final TextStyle _darkScreenCaptionTextStyle = TextStyle(
      fontSize: 12.0, color: _darkCaptionColor, fontWeight: FontWeight.w100);

  static final TextTheme _darkTextTheme = TextTheme(
    headline5: _darkScreenHeadingTextStyle,
    headline6: _darkScreenTaskNameTextStyle,
    bodyText1: _darkScreenTaskDurationTextStyle,
    bodyText2: _darkScreenTaskNameTextStyle,
    button: _darkScreenButtonTextStyle,
    subtitle1: _darkScreenTaskNameTextStyle,
    caption: _darkScreenCaptionTextStyle,
  );

  //the light theme
  static final ThemeData lightTheme = ThemeData(
    accentColor: SpotifyColors.green,
    fontFamily: AppFontFamily.proximaNova,
    scaffoldBackgroundColor: _lightPrimaryVariantColor,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightButtonPrimaryColor,
    ),
    appBarTheme: AppBarTheme(
      color: _lightAppBarColor,
      iconTheme: IconThemeData(color: _lightOnPrimaryColor),
      textTheme: _lightTextTheme,
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: Colors.white,
    ),
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      primaryVariant: _lightPrimaryVariantColor,
      secondary: _lightSecondaryColor,
      onPrimary: _lightOnPrimaryColor,
    ),
    snackBarTheme:
        SnackBarThemeData(backgroundColor: _lightSnackBarBackgroundErrorColor),
    iconTheme: IconThemeData(
      color: _lightIconColor,
    ),
    popupMenuTheme: PopupMenuThemeData(color: _lightAppBarColor),
    textTheme: _lightTextTheme,
    textSelectionColor: SpotifyColors.green.withOpacity(0.5),
    textSelectionHandleColor: SpotifyColors.green,
    buttonTheme: ButtonThemeData(
        buttonColor: _lightButtonPrimaryColor,
        textTheme: ButtonTextTheme.primary),
    unselectedWidgetColor: _lightPrimaryColor,
    inputDecorationTheme: InputDecorationTheme(
        fillColor: _lightPrimaryColor,
        labelStyle: TextStyle(
          color: _lightPrimaryColor,
        )),
    timePickerTheme: TimePickerThemeData(
      dialHandColor: SpotifyColors.green,
    ),
  );

  //the dark theme
  static final ThemeData darkTheme = ThemeData(
    accentColor: SpotifyColors.green,
    fontFamily: AppFontFamily.proximaNova,
    scaffoldBackgroundColor: _darkPrimaryVariantColor,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkButtonPrimaryColor,
    ),
    appBarTheme: AppBarTheme(
      color: _darkAppBarColor,
      iconTheme: IconThemeData(color: _darkOnPrimaryColor),
      textTheme: _darkTextTheme,
      shadowColor: _darkOnPrimaryColor,
    ),
    bottomAppBarTheme: BottomAppBarTheme(
      color: SpotifyColors.darkGray,
    ),
    colorScheme: ColorScheme.dark(
      primary: _darkPrimaryColor,
      onPrimary: _darkOnPrimaryColor,
      primaryVariant: _darkPrimaryVariantColor,
      secondary: _darkSecondaryColor,
    ),
    snackBarTheme:
        SnackBarThemeData(backgroundColor: _darkSnackBarBackgroundErrorColor),
    iconTheme: IconThemeData(
      color: _darkIconColor,
    ),
    popupMenuTheme: PopupMenuThemeData(color: _darkButtonPrimaryColor),
    textTheme: _darkTextTheme,
    textSelectionColor: SpotifyColors.green.withOpacity(0.5),
    textSelectionHandleColor: SpotifyColors.green,
    buttonTheme: ButtonThemeData(
        buttonColor: _darkButtonPrimaryColor,
        textTheme: ButtonTextTheme.primary),
    unselectedWidgetColor: _darkPrimaryColor,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: _darkPrimaryColor,
      labelStyle: TextStyle(
        color: _darkOnPrimaryColor,
      ),
    ),
    cursorColor: _darkPrimaryColor,
    timePickerTheme: TimePickerThemeData(
      dialHandColor: SpotifyColors.green,
      hourMinuteColor: SpotifyColors.darkGray,
    ),
  );
}
