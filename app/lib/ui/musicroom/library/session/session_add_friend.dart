import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../app_localizations.dart';
import '../../../../constants/spotify_color_scheme.dart';
import '../../../../services/realtime_database/databases/sessions.dart';
import '../../../../services/realtime_database/databases/users.dart';
import '../../../../models/_models.dart';

class SessionAddFriend extends StatelessWidget {
  final String userUid;
  final List<String> members;

  SessionAddFriend(this.userUid, this.members);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: getFriends(userUid),
        builder: (_, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          if (snapshot.data == 'none')
            return Text(AppLocalizations.of(context).translate('needFriends'));

          List<UserModel> friends = snapshot.data
              .where((UserModel friend) => !members.contains(friend.uid))
              .toList();
          return PopupMenuButton<String>(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              child: ListTile(
                leading: Icon(Icons.add, size: 50),
                title: Text(
                  AppLocalizations.of(context).translate('addFriend'),
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            itemBuilder: (__) {
              return friends
                  .map(
                    (friend) => PopupMenuItem(
                      value: friend.uid,
                      child: Text(friend.nickName),
                    ),
                  )
                  .toList();
            },
            onSelected: (friendUid) async {
              var sessionId = FirebaseAuth.instance.currentUser.uid;
              await addToSession(friendUid, sessionId);
            },
          );
        });
  }
}
