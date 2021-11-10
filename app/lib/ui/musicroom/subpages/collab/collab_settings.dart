import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'package:MusicRoom42/services/firestore/collections/collabs_collection.dart';
import 'package:MusicRoom42/ui/utils/toast/toast_utils.dart';

import '../../../../app_localizations.dart';
import '../../../../constants/spotify_color_scheme.dart';
import '../../../../models/_models.dart';
import '../../../../providers/spotify_app_provider.dart';
import '../../library/playlists/collabs/upsertCollabSettings/upsert_collab_settings_screen.dart';

enum CollabActions { sortEdit, settings, delete }

class CollabSettings extends StatefulWidget {
  final BuildContext collabScreenContext;
  final Collab collab;
  final Function onSortEdit;
  final SpotifyRemoteAppProvider spotifyAppProvider;
  final bool isAdmin;
  final CollabUserRights userRights;

  CollabSettings(
    this.collabScreenContext,
    this.collab,
    this.spotifyAppProvider, {
    @required this.onSortEdit,
    @required this.isAdmin,
    @required this.userRights,
  });

  @override
  _CollabSettingsState createState() => _CollabSettingsState();
}

class _CollabSettingsState extends State<CollabSettings> {
  buildMenu(BuildContext context) {
    List<Widget> list = [];
    if (widget.userRights.write == true && widget.collab.tracks.length >= 2) {
      list.add(PopupMenuItem<CollabActions>(
        value: CollabActions.sortEdit,
        child: Row(
          children: <Widget>[
            Icon(Icons.drag_handle),
            SizedBox(width: 10),
            Text(
              AppLocalizations.of(context).translate("eventSortEdit"),
            ),
          ],
        ),
      ));
    }
    if (widget.isAdmin) {
      list.add(PopupMenuItem<CollabActions>(
        value: CollabActions.settings,
        child: Row(
          children: <Widget>[
            Icon(Icons.settings),
            SizedBox(width: 10),
            Text(AppLocalizations.of(context).translate("settings")),
          ],
        ),
      ));
      list.add(PopupMenuItem<CollabActions>(
        value: CollabActions.delete,
        child: Row(
          children: <Widget>[
            Icon(Icons.delete),
            SizedBox(width: 10),
            Text(AppLocalizations.of(context).translate("delete")),
          ],
        ),
      ));
    }
    return list;
  }

  openEditCollabSettingsScreen(BuildContext context, Collab collab) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => UpsertCollabSettingsScreen(collab: collab)));
  }

  deleteAlertDialog(BuildContext context, Collab collab) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate("alertAreYouSure")),
        content:
            Text(AppLocalizations.of(context).translate("alertDeleteCollab")),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              runZonedGuarded(() {
                Navigator.pop(context);
              }, (error, stackTrace) {
                FirebaseCrashlytics.instance.recordError(error, stackTrace);
              });
            },
            child: Text(
                AppLocalizations.of(context).translate("alertDialogCancelBtn")),
          ),
          FlatButton(
            color: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () async {
              runZonedGuarded(() async {
                var isDeleted = await CollabsCollection().delete(collab.id);
                if (isDeleted) {
                  Navigator.pop(context);
                  Navigator.popUntil(
                      widget.collabScreenContext, (route) => route.isFirst);
                  ToastUtils.showCustomToast(
                    widget.collabScreenContext,
                    AppLocalizations.of(context)
                        .translate("collabDeleteSuccess"),
                  );
                } else {
                  ToastUtils.showCustomToast(
                      context,
                      AppLocalizations.of(context)
                          .translate("collabDeleteError"),
                      level: ToastLevel.Error);
                }
              }, (error, stackTrace) {
                FirebaseCrashlytics.instance.recordError(error, stackTrace);
              });
            },
            child: Text(
                AppLocalizations.of(context).translate("alertDeleteConfirm")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var listActionsMenu = buildMenu(context);
    if (listActionsMenu.length == 0) return Container();

    return widget.userRights.write == false
        ? Container()
        : PopupMenuButton<CollabActions>(
            color: Theme.of(context).brightness == Brightness.light
                ? Theme.of(context).colorScheme.lightGray
                : Theme.of(context).colorScheme.mediumGray,
            shape: Border(
              left: BorderSide(
                width: 4,
                color: Theme.of(context).accentColor,
                style: BorderStyle.solid,
              ),
            ),
            icon: Icon(Icons.more_vert),
            onSelected: (CollabActions result) {
              switch (result) {
                case CollabActions.sortEdit:
                  widget.onSortEdit();
                  break;
                case CollabActions.settings:
                  openEditCollabSettingsScreen(context, widget.collab);
                  break;
                case CollabActions.delete:
                  deleteAlertDialog(context, widget.collab);
                  break;
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<CollabActions>>[...listActionsMenu],
          );
  }
}
