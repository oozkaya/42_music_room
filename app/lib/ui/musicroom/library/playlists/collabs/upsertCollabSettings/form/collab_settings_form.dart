import 'dart:async';

import 'package:MusicRoom42/models/_models.dart';
import 'package:MusicRoom42/services/firestore/collections/collabs_collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../../../../../app_localizations.dart';
import 'collab_user_rights.dart';

class CollabSettingsForm extends StatefulWidget {
  final Collab collab;
  final List<UserModel> userFriends;
  final List<UserModel> collabUsers;
  final Function collabChangedCallback;
  final Function successCallback;

  CollabSettingsForm({
    this.collab,
    this.userFriends,
    this.collabUsers,
    this.collabChangedCallback,
    this.successCallback,
  });

  @override
  _CollabSettingsFormState createState() => _CollabSettingsFormState();
}

class _CollabSettingsFormState extends State<CollabSettingsForm> {
  final formKey = GlobalKey<FormBuilderState>();

  Collab editingCollab;
  bool isNew;

  @override
  void initState() {
    var currentUser = FirebaseAuth.instance.currentUser;
    isNew = widget.collab == null;
    editingCollab = Collab(
      id: widget.collab?.id,
      adminUserId: widget.collab?.adminUserId ?? currentUser.uid,
      adminUsername:
          widget.collab?.adminUsername ?? currentUser.displayName ?? 'Unknown',
      name: widget.collab?.name,
      nameLower: widget.collab?.nameLower,
      tracks: widget.collab?.tracks ?? [],
      rights: widget.collab?.rights ??
          CollabRights(
            isVisibilityPublic: true,
            isEditionPublic: true,
            usersRights: {},
          ),
      likes: widget.collab?.likes ?? [],
    );
    super.initState();
  }

  void updateUserRights(String userId, CollabUserRights userRights) {
    setState(() {
      if (userRights == null) {
        editingCollab.rights.usersRights.removeWhere((uid, _) => uid == userId);
      } else {
        editingCollab.rights.usersRights[userId] = userRights;
      }
      widget.collabChangedCallback();
    });
  }

  void saveCollab() async {
    formKey.currentState.save();

    String collabId = editingCollab.id;
    if (formKey.currentState.validate()) {
      if (editingCollab.rights.isEditionPublic == true &&
          editingCollab.rights.isVisibilityPublic == true) {
        editingCollab.rights.usersRights = null;
      }
      if (isNew) {
        collabId = await CollabsCollection().create(editingCollab);
      } else {
        await CollabsCollection().update(editingCollab.id, editingCollab);
      }
      if (widget.successCallback != null) widget.successCallback(collabId);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isCollabCreation = widget.collab == null;
    bool _shouldDisplayEditionToggle =
        editingCollab.rights.isVisibilityPublic == true;
    bool _shouldDisplayRightManager =
        editingCollab.rights.isVisibilityPublic == false ||
            editingCollab.rights.isEditionPublic == false;

    return ListView(
      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
      shrinkWrap: true,
      children: [
        FormBuilder(
          key: formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(children: <Widget>[
            FormBuilderTextField(
              name: 'name',
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)
                    .translate("collabPlaylistName"),
              ),
              initialValue: editingCollab.name,
              autofocus: _isCollabCreation ? true : false,
              cursorColor: Theme.of(context).accentColor,
              onChanged: (value) {
                editingCollab.name = value;
                editingCollab.nameLower = value.toLowerCase();
                if (value.length > 0) widget.collabChangedCallback();
              },
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(context),
                FormBuilderValidators.minLength(context, 3),
                FormBuilderValidators.maxLength(context, 40),
              ]),
              keyboardType: TextInputType.text,
            ),
            FormBuilderSwitch(
              name: 'visibility',
              initialValue: editingCollab.rights.isVisibilityPublic,
              title: Text(AppLocalizations.of(context).translate("visibility")),
              subtitle: Text(AppLocalizations.of(context)
                  .translate("collabVisibilityEnabled")),
              activeColor: Theme.of(context).accentColor,
              onChanged: (value) => setState(() {
                editingCollab.rights.isVisibilityPublic = value;
                if (value == false) {
                  editingCollab.rights.isEditionPublic = false;
                }
                widget.collabChangedCallback();
              }),
            ),
            _shouldDisplayEditionToggle
                ? FormBuilderSwitch(
                    name: 'edition',
                    initialValue: editingCollab.rights.isEditionPublic,
                    title:
                        Text(AppLocalizations.of(context).translate("edition")),
                    subtitle: Text(AppLocalizations.of(context)
                        .translate("collabEditionEnabled")),
                    activeColor: Theme.of(context).accentColor,
                    onChanged: (value) => setState(() {
                      editingCollab.rights.isEditionPublic = value;
                      widget.collabChangedCallback();
                    }),
                  )
                : Container(),
            _shouldDisplayRightManager
                ? UserRights(
                    editingCollab: editingCollab,
                    userFriends: widget.userFriends,
                    updateUserRights: updateUserRights,
                    formKey: formKey,
                  )
                : Container()
          ]),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
          child: RaisedButton(
            child: Text(AppLocalizations.of(context)
                .translate(isNew ? "collabCreate" : "save")),
            textColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            onPressed: () {
              runZonedGuarded(() {
                saveCollab();
              }, (error, stackTrace) {
                FirebaseCrashlytics.instance.recordError(error, stackTrace);
              });
            },
          ),
        ),
      ],
    );
  }
}
