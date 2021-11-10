import 'package:flutter/material.dart';

import './ui/auth/register_screen.dart';
import './ui/auth/sign_in_screen.dart';
import './ui/auth/verify_screen.dart';
import './ui/home/home.dart';
import './ui/musicroom/players/player_screen.dart';
import './ui/setting/setting_screen.dart';
import './ui/splash/splash_screen.dart';

class Routes {
  Routes._(); //this is to prevent anyone from instantiate this object

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String verify = '/verify';
  static const String home = '/home';
  static const String musicroom_player = '/musicroom/player';
  static const String musicroom_setting = '/setting';

  static final routes = <String, WidgetBuilder>{
    splash: (BuildContext context) => SplashScreen(),
    login: (BuildContext context) => SignInScreen(),
    register: (BuildContext context) => RegisterScreen(),
    verify: (BuildContext context) => VerifyScreen(),
    home: (BuildContext context) => HomeScreen(),
    musicroom_player: (BuildContext context) => PlayerScreen(),
    musicroom_setting: (BuildContext context) => SettingScreen(),
  };
}
