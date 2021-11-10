import 'dart:async';

import 'package:MusicRoom42/providers/spotify_player_provider.dart';
import 'package:MusicRoom42/ui/setting/friends/setting_friends_screen.dart';
import 'package:MusicRoom42/ui/setting/setting_profile_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../routes.dart';
import '../setting/setting_language_actions.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate("settingAppTitle")),
      ),
      body: _buildLayoutSection(context),
    );
  }

  Widget _buildLayoutSection(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text(
              AppLocalizations.of(context).translate("settingThemeListTitle")),
          subtitle: Text(AppLocalizations.of(context)
              .translate("settingThemeListSubTitle")),
          trailing: Switch(
            activeColor: Theme.of(context).accentColor,
            activeTrackColor: Theme.of(context).textTheme.headline6.color,
            value: Provider.of<ThemeProvider>(context).isDarkModeOn,
            onChanged: (booleanValue) {
              Provider.of<ThemeProvider>(context, listen: false)
                  .updateTheme(booleanValue);
            },
          ),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)
              .translate("settingLanguageListTitle")),
          subtitle: Text(AppLocalizations.of(context)
              .translate("settingLanguageListSubTitle")),
          trailing: SettingLanguageActions(),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)
              .translate("settingProfileListTitle")),
          subtitle: Text(AppLocalizations.of(context)
              .translate("settingProfileListSubTitle")),
          trailing: IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              runZonedGuarded(() {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => SettingProfileScreen()));
              }, (error, stackTrace) {
                FirebaseCrashlytics.instance.recordError(error, stackTrace);
              });
            },
          ),
        ),
        ListTile(
          title: Text(AppLocalizations.of(context)
              .translate("settingFriendsListTitle")),
          subtitle: Text(AppLocalizations.of(context)
              .translate("settingFriendsListSubTitle")),
          trailing: IconButton(
            icon: Icon(Icons.supervisor_account),
            onPressed: () {
              runZonedGuarded(() {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => SettingFriendsScreen()));
              }, (error, stackTrace) {
                FirebaseCrashlytics.instance.recordError(error, stackTrace);
              });
            },
          ),
        ),
        ListTile(
          title: Text(
              AppLocalizations.of(context).translate("settingLogoutListTitle")),
          subtitle: Text(AppLocalizations.of(context)
              .translate("settingLogoutListSubTitle")),
          trailing: RaisedButton(
              color: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              onPressed: () {
                runZonedGuarded(() {
                  _confirmSignOut(context);
                }, (error, stackTrace) {
                  FirebaseCrashlytics.instance.recordError(error, stackTrace);
                });
              },
              child: Text(AppLocalizations.of(context)
                  .translate("settingLogoutButton"))),
        ),
      ],
    );
  }

  _confirmSignOut(BuildContext context) {
    showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
              android: (_) => MaterialAlertDialogData(
                  backgroundColor: Theme.of(context).bottomAppBarTheme.color),
              title: Text(
                  AppLocalizations.of(context).translate("alertDialogTitle")),
              content: Text(
                  AppLocalizations.of(context).translate("alertDialogMessage")),
              actions: <Widget>[
                PlatformDialogAction(
                  child: PlatformText(AppLocalizations.of(context)
                      .translate("alertDialogCancelBtn")),
                  onPressed: () {
                    runZonedGuarded(() {
                      Navigator.of(context, rootNavigator: true).pop(false);
                    }, (error, stackTrace) {
                      FirebaseCrashlytics.instance
                          .recordError(error, stackTrace);
                    });
                  },
                ),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.red,
                  ),
                  child: PlatformDialogAction(
                    child: PlatformText(AppLocalizations.of(context)
                        .translate("alertDialogYesBtn")),
                    onPressed: () {
                      runZonedGuarded(() async {
                        final playerProvider =
                            Provider.of<SpotifyPlayerProvider>(context,
                                listen: false);
                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);

                        playerProvider.close();
                        await authProvider.googleSignOut(context);

                        Navigator.pop(context);
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.login, ModalRoute.withName(Routes.login));
                      }, (error, stackTrace) {
                        FirebaseCrashlytics.instance
                            .recordError(error, stackTrace);
                      });
                    },
                  ),
                )
              ],
            ));
  }
}
