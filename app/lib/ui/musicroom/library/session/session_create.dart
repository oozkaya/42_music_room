import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app_localizations.dart';
import '../../../../providers/spotify_player_provider.dart';
import '../../../../services/realtime_database/databases/sessions.dart';
import '../../../../services/spotify/player_basics.dart';
import '../../../../ui/musicroom/library/session/session_tabs.dart';

class CreateSession extends StatefulWidget {
  @override
  _CreateSessionState createState() => _CreateSessionState();
}

class _CreateSessionState extends State<CreateSession> {
  @override
  Widget build(BuildContext context) {
    SpotifyPlayerProvider playerProvider =
        Provider.of<SpotifyPlayerProvider>(context, listen: false);
    var sessionTabsState = context.findAncestorStateOfType<SessionTabsState>();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context).translate("sessionNone"),
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          RaisedButton(
            child: Text(
              AppLocalizations.of(context).translate("sessionCreate"),
              style: TextStyle(fontSize: 20),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () async {
              runZonedGuarded(() async {
                await pause();
                playerProvider.setIsPaused(true);
                await createSession(playerProvider);
                sessionTabsState.setState(() {});
              }, (error, stackTrace) {
                FirebaseCrashlytics.instance.recordError(error, stackTrace);
              });
            },
          )
        ],
      ),
    );
  }
}
