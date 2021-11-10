import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import '../../../services/spotify/api/handleCredentials.dart';
import '../../../app_localizations.dart';
import '../../../providers/spotify_app_provider.dart';
import '../../../ui/splash/splash_screen.dart';

class SpotifyConnectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SpotifyRemoteAppProvider remoteAppProvider = Provider.of(context);

    return StreamBuilder<ConnectionStatus>(
      stream: SpotifySdk.subscribeConnectionStatus(),
      builder: (context, snapshot) {
        var isConnected = remoteAppProvider.getStreamConnectionStatus(snapshot);
        if (isConnected) {
          return SplashScreen();
        }
        return _screen(context);
      },
    );
  }

  Widget _screen(BuildContext context) {
    final SpotifyRemoteAppProvider remoteAppProvider = Provider.of(context);

    bool isNotInstalled =
        remoteAppProvider.appErrorCode == "CouldNotFindSpotifyApp";
    bool isNotLoggedIn =
        remoteAppProvider.appErrorCode == "NotLoggedInException";

    String getErrorMessage() {
      if (isNotInstalled)
        return AppLocalizations.of(context).translate("spotifyIsNotInstalled");
      if (isNotLoggedIn)
        return AppLocalizations.of(context).translate("spotifyIsNotLoggedIn");
      return '';
    }

    String getHint() {
      if (isNotInstalled)
        return AppLocalizations.of(context)
            .translate("spotifyIsNotInstalledHint");
      if (isNotLoggedIn)
        return AppLocalizations.of(context)
            .translate("spotifyIsNotLoggedInHint");
      return AppLocalizations.of(context).translate("spotifyBindHint");
    }

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
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
          child: Center(
              child: Text(
            getErrorMessage(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headline6.fontSize,
            ),
          )),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
          child: Center(
              child: Text(
            getHint(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headline5.fontSize,
            ),
          )),
        ),
        isNotInstalled
            ? Container()
            : Padding(
                padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                child: RaisedButton(
                  child: Text(AppLocalizations.of(context)
                      .translate("spotifyConnectButton")),
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: () {
                    runZonedGuarded(() {
                      handleCredentials(remoteAppProvider);
                    }, (error, stackTrace) {
                      FirebaseCrashlytics.instance
                          .recordError(error, stackTrace);
                    });
                  },
                ),
              ),
      ],
    )));
  }
}
