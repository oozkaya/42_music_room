import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import './app_localizations.dart';
import './auth_widget_builder.dart';
import './constants/app_themes.dart';
import './flavor.dart';
import './models/_models.dart';
import './providers/auth_provider.dart';
import './providers/language_provider.dart';
import './providers/spotify_app_provider.dart';
import './providers/theme_provider.dart';
import './routes.dart';
import './services/firestore/firestore_database.dart';
import './ui/auth/sign_in_screen.dart';
import './ui/auth/verify_screen.dart';
import './ui/loading/loading.dart';
import './ui/musicroom/spotifyConnection/spotify_connection_screen.dart';

class MyApp extends StatelessWidget {
  MyApp({Key key, this.databaseBuilder}) : super(key: key);

  // Expose builders for 3rd party services at the root of the widget tree
  // This is useful when mocking services while testing
  final FirestoreDatabase Function(BuildContext context, String uid)
      databaseBuilder;
  final auth = FirebaseAuth.instance;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, themeProviderRef, __) {
        //{context, data, child}
        return Consumer<LanguageProvider>(
            builder: (_, languageProviderRef, __) {
          return AuthWidgetBuilder(
            databaseBuilder: databaseBuilder,
            builder:
                (BuildContext context, AsyncSnapshot<UserModel> userSnapshot) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                locale: languageProviderRef.appLocale,
                //List of all supported locales
                supportedLocales: [
                  Locale('en', 'US'),
                  Locale('fr', 'FR'),
                ],
                //These delegates make sure that the localization data for the proper language is loaded
                localizationsDelegates: [
                  //A class which loads the translations from JSON files
                  AppLocalizations.delegate,
                  //Built-in localization of basic text for Material widgets (means those default Material widget such as alert dialog icon text)
                  GlobalMaterialLocalizations.delegate,
                  //Built-in localization for text direction LTR/RTL
                  GlobalWidgetsLocalizations.delegate,
                  // localization for FormBuilderLocalizations
                  FormBuilderLocalizations.delegate,
                ],
                //return a locale which will be used by the app
                localeResolutionCallback: (locale, supportedLocales) {
                  //check if the current device locale is supported or not
                  for (var supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode == locale?.languageCode ||
                        supportedLocale.countryCode == locale?.countryCode) {
                      return supportedLocale;
                    }
                  }
                  //if the locale from the mobile device is not supported yet,
                  //user the first one from the list (in our case, that will be English)
                  return supportedLocales.first;
                },
                title: Provider.of<Flavor>(context).toString(),
                routes: Routes.routes,
                theme: AppThemes.lightTheme,
                darkTheme: AppThemes.darkTheme,
                themeMode: themeProviderRef.isDarkModeOn
                    ? ThemeMode.dark
                    : ThemeMode.light,
                home: Consumer<AuthProvider>(
                  builder: (_, authProviderRef, __) {
                    if (userSnapshot.connectionState != ConnectionState.active)
                      return LoadingWidget();
                    if (!userSnapshot.hasData) return SignInScreen();
                    User user = auth.currentUser;
                    if (!user.emailVerified) return VerifyScreen();
                    return Consumer<SpotifyRemoteAppProvider>(
                      builder: (_, spotifyProviderRef, __) {
                        return SpotifyConnectionScreen();
                      },
                    );
                  },
                ),
              );
            },
          );
        });
      },
    );
  }
}
