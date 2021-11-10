import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../../../../app_localizations.dart';
import '../../../../models/_models.dart';
import '../../../../services/realtime_database/databases/sessions.dart';
import '../../../../services/realtime_database/databases/users.dart';
import '../../../../ui/musicroom/library/session/session_add_friend.dart';
import '../../../../ui/musicroom/library/session/session_tabs.dart';

class SessionMembers extends StatefulWidget {
  final List<String> members;
  final String adminUid;

  SessionMembers(this.members, this.adminUid);

  @override
  _SessionMembersState createState() => _SessionMembersState();
}

class _SessionMembersState extends State<SessionMembers> {
  final String userUid = FirebaseAuth.instance.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    var sessionTabsState = context.findAncestorStateOfType<SessionTabsState>();

    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).translate("sessionLive"),
              style: TextStyle(fontSize: 25),
            ),
            SizedBox(height: 20),
            FutureBuilder(
              future: getSpecificUsers(widget.members),
              builder: (_, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                List<UserModel> users = snapshot.data;
                return Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: ListView.builder(
                    key: UniqueKey(),
                    shrinkWrap: true,
                    itemCount: users.length + 1,
                    itemBuilder: (__, index) {
                      bool isAdmin = widget.adminUid == userUid;
                      bool isItemAdmin = index < users.length &&
                          widget.adminUid == users[index].uid;
                      bool isItemCurrentUser =
                          index < users.length && users[index].uid == userUid;
                      bool canAddFriend =
                          index == users.length && users.length < 5;

                      if (isAdmin && canAddFriend)
                        return SessionAddFriend(userUid, widget.members);
                      if (!isAdmin && index >= users.length) return Container();
                      if (index >= 5) return Container();

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          leading: Icon(
                            isItemAdmin ? Icons.stars : Icons.account_circle,
                            size: 50,
                          ),
                          title: Text(
                            users[index].nickName,
                            style: TextStyle(fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: isAdmin && !isItemCurrentUser
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    size: 30,
                                  ),
                                  onPressed: () async {
                                    runZonedGuarded(() async {
                                      await kickFromSession(
                                          users[index].uid, widget.adminUid);
                                    }, (error, stackTrace) {
                                      FirebaseCrashlytics.instance
                                          .recordError(error, stackTrace);
                                    });
                                  },
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            RaisedButton(
              child: widget.adminUid == userUid
                  ? Text(AppLocalizations.of(context).translate("closeSession"))
                  : Text(
                      AppLocalizations.of(context).translate("leaveSession")),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              onPressed: () async {
                runZonedGuarded(() async {
                  widget.adminUid == userUid
                      ? await cleanSession(widget.adminUid)
                      : await kickFromSession(userUid, widget.adminUid);
                  sessionTabsState.setState(() {});
                }, (error, stackTrace) {
                  FirebaseCrashlytics.instance.recordError(error, stackTrace);
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
