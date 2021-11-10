import 'dart:async';

import 'package:MusicRoom42/ui/musicroom/spotifyConnection/spotify_connection_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../../app_localizations.dart';
import '../../routes.dart';
import './user_infos_screen.dart';

class VerifyScreen extends StatefulWidget {
  VerifyScreen({Key key}) : super(key: key);

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final auth = FirebaseAuth.instance;
  User user;
  Timer timer;

  Future<void> checkEmailVerified() async {
    user = auth.currentUser;
    await user.reload();
    if (user.emailVerified) {
      timer.cancel();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => SpotifyConnectionScreen()));
    }
  }

  @override
  void initState() {
    user = auth.currentUser;
    user.sendEmailVerification();
    timer = Timer.periodic(Duration(seconds: 2), (t) {
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context).translate("loginVerifyEmail") +
                  " (${user.email})",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            FlatButton(
              child: Text(
                  AppLocalizations.of(context).translate("loginReturnBack")),
              color: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              onPressed: () async {
                runZonedGuarded(() async {
                  await auth.signOut();
                  Navigator.of(context).pushReplacementNamed(Routes.login);
                }, (error, stackTrace) {
                  FirebaseCrashlytics.instance.recordError(error, stackTrace);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
