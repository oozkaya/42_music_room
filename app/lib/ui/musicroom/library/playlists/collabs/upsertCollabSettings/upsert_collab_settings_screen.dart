import 'dart:async';

import 'package:MusicRoom42/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../../../../../../models/_models.dart';
import '../../../../../../services/realtime_database/databases/users.dart';
import '../../../../../../utils/dart/KeepAliveFutureBuilder.dart';
import 'form/collab_settings_form.dart';

class UpsertCollabSettingsScreen extends StatefulWidget {
  final Collab collab;
  final Function successCallback;

  UpsertCollabSettingsScreen({this.collab, this.successCallback});

  @override
  _UpsertCollabSettingsScreenState createState() =>
      _UpsertCollabSettingsScreenState();
}

class _UpsertCollabSettingsScreenState
    extends State<UpsertCollabSettingsScreen> {
  List<UserModel> userFriends = [];
  List<UserModel> collabUsers = [];
  bool hasCollabChanged = false;

  Future<bool> _asyncInit() async {
    var currentUser = FirebaseAuth.instance.currentUser;

    var collabUsersIds = widget.collab?.rights?.usersRights?.keys?.toList();
    await Future.wait([
      getFriends(currentUser.uid).then((res) {
        if (res is List<UserModel>) userFriends = res;
      }),
      getUsersFromUids(collabUsersIds).then((res) => collabUsers = res),
    ]);
    return true;
  }

  Future<bool> onCancel(BuildContext context, bool hasCollabChanged) async {
    if (hasCollabChanged == false) {
      Navigator.of(context).pop(true);
      return true;
    }
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context).translate('alertAreYouSure'),
            ),
            content: Text(
              AppLocalizations.of(context)
                  .translate('alertGoBackWithoutSaving'),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  runZonedGuarded(() {
                    Navigator.of(context).pop(true);
                  }, (error, stackTrace) {
                    FirebaseCrashlytics.instance.recordError(error, stackTrace);
                  });
                },
                child: Text(
                  AppLocalizations.of(context).translate('alertDialogQuitBtn'),
                ),
              ),
              FlatButton(
                color: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                onPressed: () {
                  runZonedGuarded(() {
                    Navigator.of(context).pop(false);
                  }, (error, stackTrace) {
                    FirebaseCrashlytics.instance.recordError(error, stackTrace);
                  });
                },
                child: Text(
                  AppLocalizations.of(context).translate('alertSaveFirst'),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  bool collabChanged() => hasCollabChanged = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onCancel(context, hasCollabChanged),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(
            widget.collab == null
                ? AppLocalizations.of(context).translate('collabCreate')
                : widget.collab.name,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shadowColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: KeepAliveFutureBuilder(
          future: _asyncInit(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              return CollabSettingsForm(
                collab: widget.collab,
                userFriends: userFriends,
                collabUsers: collabUsers,
                collabChangedCallback: collabChanged,
                successCallback: widget.successCallback,
              );
            }
          },
        ),
      ),
    );
  }
}
