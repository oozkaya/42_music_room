import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../../../app_localizations.dart';
import '../../../../../models/_models.dart';
import '../../../../../services/realtime_database/databases/users.dart';
import '../../../../../services/firestore/collections/events_collection.dart';
import '../../../../../utils/dart/KeepAliveFutureBuilder.dart';
import 'form/event_settings_form.dart';

class UpsertEventSettingsScreen extends StatefulWidget {
  final EventModel event;
  final Function successCallback;

  UpsertEventSettingsScreen({this.event, this.successCallback});

  @override
  _UpsertEventSettingsScreenState createState() =>
      _UpsertEventSettingsScreenState();

  static _UpsertEventSettingsScreenState of(BuildContext context) =>
      context.findAncestorStateOfType<_UpsertEventSettingsScreenState>();
}

class _UpsertEventSettingsScreenState extends State<UpsertEventSettingsScreen> {
  List<UserModel> userFriends = [];
  List<UserModel> eventUsers = [];
  EventModel editingEvent;
  bool isNew;
  bool hasEventChanged = false;

  final formKey = GlobalKey<FormBuilderState>();

  Future<bool> _asyncInit() async {
    var currentUser = FirebaseAuth.instance.currentUser;

    var eventUsersIds = widget.event?.usersRights?.keys?.toList();
    await Future.wait([
      getFriends(currentUser.uid).then((res) {
        if (res is List<UserModel>) userFriends = res;
      }),
      getUsersFromUids(eventUsersIds).then((res) => eventUsers = res),
    ]);
    return true;
  }

  @override
  void initState() {
    var currentUser = FirebaseAuth.instance.currentUser;
    isNew = widget.event == null;
    editingEvent = EventModel(
      id: widget.event?.id,
      adminUserId: widget.event?.adminUserId ?? currentUser.uid,
      adminUsername:
          widget.event?.adminUsername ?? currentUser.displayName ?? 'Unknown',
      isPublic: widget.event?.isPublic ?? true,
      name: widget.event?.name ?? '',
      nameLower:
          widget.event?.nameLower ?? widget.event?.name?.toLowerCase() ?? '',
      tracks: widget.event?.tracks ?? [],
      usersRights: widget.event?.usersRights ?? {},
      followers: widget.event?.followers ?? [],
      settings: widget.event?.settings ??
          EventSettings(
            isLocationRestrictionEnabled: false,
            isTimeRestrictionEnabled: false,
          ),
      keywords: widget.event?.keywords ?? [],
      playbackPosition: widget.event?.playbackPosition ?? 0,
      playbackPositionStartTime: widget.event?.playbackPositionStartTime ?? 0,
      isPaused: widget.event?.isPaused ?? true,
      membersCounter: widget.event?.membersCounter ?? 0,
    );
    super.initState();
  }

  void updateSettings(EventSettings newSettings) {
    setState(() {
      editingEvent.settings = newSettings;
      hasEventChanged = true;
    });
  }

  void updateUserRights(String userId, EventUsersRights userRights) {
    setState(() {
      if (userRights == null) {
        editingEvent.usersRights.removeWhere((uid, _) => uid == userId);
      } else {
        editingEvent.usersRights[userId] = userRights;
      }
      hasEventChanged = true;
    });
  }

  Future<void> saveEvent() async {
    runZonedGuarded(() async {
      if (formKey.currentState.validate()) {
        EventModel evt;
        if (editingEvent.isPublic == true) {
          editingEvent.usersRights = null;
        }
        if (isNew) {
          evt = await EventsCollection().createEvent(editingEvent);
        } else {
          evt = await EventsCollection().updateEvent(
            widget.event.id,
            editingEvent.toJson(), // eventJson,
          );
        }
        if (widget.successCallback != null) {
          widget.successCallback(evt.id);
        }
        Navigator.pop(context);
      }
    }, (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    });
  }

  Future<bool> onCancel(BuildContext context, bool hasEventChanged) async {
    if (hasEventChanged == false) {
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

  void eventChanged() => setState(() => hasEventChanged = true);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onCancel(context, hasEventChanged),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(
            widget.event == null
                ? AppLocalizations.of(context).translate('eventCreate')
                : widget.event.name,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            hasEventChanged
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                    child: IconButton(
                      icon: Icon(Icons.check),
                      iconSize: 30,
                      onPressed: () {
                        runZonedGuarded(() {
                          saveEvent();
                        }, (error, stackTrace) {
                          FirebaseCrashlytics.instance
                              .recordError(error, stackTrace);
                        });
                      },
                      color: Theme.of(context).accentColor,
                    ),
                  )
                : Container()
          ],
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shadowColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: KeepAliveFutureBuilder(
          future: _asyncInit(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            } else {
              return EventSettingsForm(
                editingEvent: editingEvent,
                userFriends: userFriends,
                eventUsers: eventUsers,
                eventChangedCallback: eventChanged,
              );
            }
          },
        ),
      ),
    );
  }
}
