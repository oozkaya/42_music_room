import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../app_localizations.dart';
import '../../routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Image(
          image: AssetImage('assets/images/music_frequencies_green.png'),
          height: 200,
        ),
        Center(
            child: Text(
          AppLocalizations.of(context).translate("splashTitle"),
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.headline5.fontSize,
          ),
        )),
      ],
    )));
  }

  startTimer() {
    var duration = Duration(milliseconds: int.parse(env['SPLASH_DURATION_MS']));
    return Timer(duration, redirect);
  }

  redirect() async {
    Navigator.of(context).pushReplacementNamed(Routes.home);
  }
}
