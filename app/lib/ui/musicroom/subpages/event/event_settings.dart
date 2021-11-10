import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../../../../models/_models.dart';
import '../../../../app_localizations.dart';
import '../../../../constants/spotify_color_scheme.dart';
import '../../../../providers/spotify_app_provider.dart';
import '../../../../ui/utils/toast/toast_utils.dart';
// import '../../../../ui/musicroom/library/events/user_events.dart';
import '../../../../services/firestore/collections/events_collection.dart';
import '../../library/events/upsertEvent/upsert_event_settings_screen.dart';

enum EventActions { sortTracks, updateEvent, delete }

class EventSettings extends StatelessWidget {
  final BuildContext eventScreenContext;
  final EventModel evt;
  final Function onSortEdit;
  final bool hasTracks;
  final SpotifyRemoteAppProvider spotifyAppProvider;

  EventSettings(
    this.eventScreenContext,
    this.evt,
    this.spotifyAppProvider, {
    @required this.hasTracks,
    @required this.onSortEdit,
  });

  updateEvent(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => UpsertEventSettingsScreen(event: evt)));
  }

  deleteAlertDialog(BuildContext context, EventModel event) {
    // UserEventsState userEventsState =
    //     context.findAncestorStateOfType<UserEventsState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate("alertAreYouSure")),
        content:
            Text(AppLocalizations.of(context).translate("alertDeleteEvent")),
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
                var isDeleted = await EventsCollection().deleteEvent(event.id);
                if (isDeleted) {
                  // userEventsState?.setState(() {});
                  Navigator.pop(context);
                  Navigator.popUntil(
                      eventScreenContext, (route) => route.isFirst);
                  ToastUtils.showCustomToast(
                    eventScreenContext,
                    AppLocalizations.of(context)
                        .translate("eventDeleteSuccess"),
                  );
                } else {
                  ToastUtils.showCustomToast(
                      context,
                      AppLocalizations.of(context)
                          .translate("eventDeleteError"),
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

  buildMenu(BuildContext context) {
    List<PopupMenuItem> list = [];
    bool hasRights = false;
    String uid = FirebaseAuth.instance.currentUser.uid;
    if (this.evt.usersRights != null && this.evt.usersRights[uid] != null) {
      hasRights = this.evt.usersRights[uid].edit == true;
    }
    if (this.evt.adminUserId == uid || hasRights) {
      if (hasTracks && evt.tracks.length >= 2) {
        list.add(PopupMenuItem<EventActions>(
          value: EventActions.sortTracks,
          child: Row(
            children: <Widget>[
              Icon(Icons.drag_handle),
              SizedBox(width: 10),
              Text(AppLocalizations.of(context).translate("eventSortEdit"),
                  style: TextStyle()),
            ],
          ),
        ));
      }
    }
    if (this.evt.adminUserId == uid) {
      list.add(PopupMenuItem<EventActions>(
        value: EventActions.updateEvent,
        child: Row(
          children: <Widget>[
            Icon(Icons.settings),
            SizedBox(width: 10),
            Text(AppLocalizations.of(context).translate("settings")),
          ],
        ),
      ));
      list.add(PopupMenuItem<EventActions>(
        value: EventActions.delete,
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

  @override
  Widget build(BuildContext context) {
    var listWidgetsMenu = buildMenu(context);

    if (listWidgetsMenu.length == 0) return Container();

    return PopupMenuButton<EventActions>(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[300]
          : Theme.of(context).colorScheme.mediumGray,
      shape: Border(
        left: BorderSide(
          width: 4,
          color: Theme.of(context).accentColor,
          style: BorderStyle.solid,
        ),
      ),
      icon: Icon(Icons.more_vert),
      onSelected: (EventActions result) {
        switch (result) {
          case EventActions.sortTracks:
            this.onSortEdit();
            break;
          case EventActions.updateEvent:
            this.updateEvent(context);
            break;
          case EventActions.delete:
            this.deleteAlertDialog(context, evt);
            break;
        }
      },
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<EventActions>>[...listWidgetsMenu],
    );
  }
}
