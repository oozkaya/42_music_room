import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../../../../ui/setting/setting_screen.dart';
import '../../../../app_localizations.dart';

class TAHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Text(
            AppLocalizations.of(context).translate("topArtists"),
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.settings),
          iconSize: 30,
          onPressed: () {
            runZonedGuarded(() {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingScreen()));
            }, (error, stackTrace) {
              FirebaseCrashlytics.instance.recordError(error, stackTrace);
            });
          },
        ),
      ],
    );
  }
}
