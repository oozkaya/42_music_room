import 'dart:async';

import 'package:MusicRoom42/app_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../models/_models.dart';
import '../../../utils/dart/stringsExtension.dart';
import '../../utils/toast/toast_utils.dart';

class CollabUserRightsTile extends StatelessWidget {
  final UserModel userData;
  final CollabUserRights userRights;
  final Function updateUserRights;

  const CollabUserRightsTile(
      {this.userData, this.userRights, this.updateUserRights});

  @override
  Widget build(BuildContext context) {
    if (userRights == null) return Container();

    var rightsAsString = '';
    userRights?.toJson()?.forEach((key, value) {
      if (value == true) rightsAsString += key.capitalize() + ' ';
    });

    return Slidable(
      key: ObjectKey(userData.uid),
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.15,
      child: ListTile(
        visualDensity: VisualDensity(horizontal: 0, vertical: -3),
        contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 30),
          ],
        ),
        title: Text(
          userData.nickName,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyText2.fontSize,
          ),
        ),
        subtitle: Text(
          rightsAsString,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
          ),
        ),
        trailing: Wrap(
          children: [
            IconButton(
              icon: Icon(Icons.visibility),
              color: Theme.of(context).accentColor,
              onPressed: () {
                runZonedGuarded(() {
                  ToastUtils.showCustomToast(
                    context,
                    AppLocalizations.of(context)
                        .translate('userRightsRemoveFriend'),
                  );
                }, (error, stackTrace) {
                  FirebaseCrashlytics.instance.recordError(error, stackTrace);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.edit),
              color: userRights.write
                  ? Theme.of(context).accentColor
                  : Theme.of(context).colorScheme.secondary,
              onPressed: () {
                runZonedGuarded(() {
                  var updatedRights =
                      CollabUserRights.fromCollabUserRights(userRights);
                  updatedRights.write = !updatedRights.write;
                  updateUserRights(userData.uid, updatedRights);
                }, (error, stackTrace) {
                  FirebaseCrashlytics.instance.recordError(error, stackTrace);
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => updateUserRights(userData.uid, null),
        ),
      ],
    );
  }
}
