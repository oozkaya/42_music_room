import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import './flavor.dart';
import './my_app.dart';
import './providers/auth_provider.dart';
import './providers/language_provider.dart';
import './providers/theme_provider.dart';
import './providers/spotify_app_provider.dart';
import './providers/spotify_player_provider.dart';
import 'services/firestore/firestore_database.dart';

void main() async {
  await DotEnv.load(fileName: ".env");
  // Logger.level = Level.verbose;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      // .then((_) async {
      .then((_) {
    runZonedGuarded(() {
      runApp(
        /*
      * MultiProvider for top services that do not depends on any runtime values
      * such as user uid/email.
       */
        MultiProvider(
          providers: [
            Provider<Flavor>.value(value: Flavor.dev),
            ChangeNotifierProvider<ThemeProvider>(
              create: (context) => ThemeProvider(),
            ),
            ChangeNotifierProvider<AuthProvider>(
              create: (context) => AuthProvider(),
            ),
            ChangeNotifierProvider<LanguageProvider>(
              create: (context) => LanguageProvider(),
            ),
            ChangeNotifierProvider<SpotifyPlayerProvider>(
              create: (context) => SpotifyPlayerProvider(context),
            ),
            ChangeNotifierProvider<SpotifyRemoteAppProvider>(
              create: (context) => SpotifyRemoteAppProvider(),
            ),
          ],
          child: MyApp(
            databaseBuilder: (_, uid) => FirestoreDatabase(uid: uid),
          ),
        ),
      );
    }, (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    });
  });
}
