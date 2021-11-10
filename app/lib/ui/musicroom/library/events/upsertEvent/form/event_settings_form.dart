import 'dart:async';

import 'package:MusicRoom42/ui/musicroom/library/events/upsertEvent/upsert_event_settings_screen.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../../../../app_localizations.dart';
import '../../../../../../models/_models.dart';
import 'restrictions/event_restrictions.dart';
import 'rights/event_user_rights.dart';

class EventSettingsForm extends StatefulWidget {
  final EventModel editingEvent;
  final List<UserModel> userFriends;
  final List<UserModel> eventUsers;
  final Function eventChangedCallback;

  EventSettingsForm({
    this.editingEvent,
    this.userFriends,
    this.eventUsers,
    this.eventChangedCallback,
  });

  @override
  _EventSettingsFormState createState() => _EventSettingsFormState();
}

class _EventSettingsFormState extends State<EventSettingsForm> {
  @override
  Widget build(BuildContext context) {
    bool _isEventCreation = UpsertEventSettingsScreen.of(context).isNew;
    bool _hasEventChanged =
        UpsertEventSettingsScreen.of(context).hasEventChanged;
    bool _shouldDisplayRightManager = widget.editingEvent.isPublic == false;

    return ListView(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
      shrinkWrap: true,
      children: [
        FormBuilder(
          key: UpsertEventSettingsScreen.of(context).formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: FormBuilderTextField(
                name: 'name',
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)
                      .translate("eventPlaylistName"),
                ),
                initialValue: widget.editingEvent.name,
                autofocus: _isEventCreation ? true : false,
                cursorColor: Theme.of(context).accentColor,
                onChanged: (value) {
                  widget.editingEvent.name = value;
                  widget.editingEvent.nameLower = value.toLowerCase();
                  if (value.length > 0) widget.eventChangedCallback();
                },
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(context),
                  FormBuilderValidators.minLength(context, 3),
                  FormBuilderValidators.maxLength(context, 40),
                ]),
                keyboardType: TextInputType.text,
              ),
            ),
            SizedBox(height: 20),
            FormBuilderField(
              name: "visibility",
              initialValue: widget.editingEvent.isPublic,
              builder: (FormFieldState<dynamic> field) {
                return ListTile(
                  leading: Icon(
                    widget.editingEvent.isPublic ? Icons.lock_open : Icons.lock,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: Text(AppLocalizations.of(context)
                      .translate("eventVisibilityEnabled")),
                  trailing: Switch(
                    value: widget.editingEvent.isPublic,
                    onChanged: (value) => setState(() {
                      widget.editingEvent.isPublic = value;
                      widget.eventChangedCallback();
                    }),
                    activeColor: Theme.of(context).accentColor,
                  ),
                );
              },
            ),
            _shouldDisplayRightManager
                ? EventUserRights(
                    editingEvent: widget.editingEvent,
                    userFriends: widget.userFriends,
                    updateUserRights:
                        UpsertEventSettingsScreen.of(context).updateUserRights,
                  )
                : Container()
          ]),
        ),
        EventRestrictions(
          widget.editingEvent.settings,
          UpsertEventSettingsScreen.of(context).updateSettings,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 20, 50, 0),
          child: RaisedButton(
            child: Text(AppLocalizations.of(context)
                .translate(_isEventCreation ? "eventCreate" : "save")),
            textColor: Theme.of(context).colorScheme.onPrimary,
            color: _hasEventChanged
                ? Theme.of(context).accentColor
                : Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () {
              if (_hasEventChanged) {
                runZonedGuarded(() {
                  UpsertEventSettingsScreen.of(context).saveEvent();
                }, (error, stackTrace) {
                  FirebaseCrashlytics.instance.recordError(error, stackTrace);
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
