import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../../../services/realtime_database/databases/users.dart';
import '../../../app_localizations.dart';
import '../../../models/_models.dart';
import './friends_search.dart';

class SettingFriendsScreen extends StatefulWidget {
  SettingFriendsScreen({Key key}) : super(key: key);

  @override
  _SettingFriendsScreenState createState() => _SettingFriendsScreenState();
}

class _SettingFriendsScreenState extends State<SettingFriendsScreen> {
  @override
  Widget build(BuildContext context) {
    String userUid = FirebaseAuth.instance.currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            AppLocalizations.of(context).translate("settingFriendsListTitle")),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              runZonedGuarded(() {
                showSearch(context: context, delegate: FriendsSearch(setState));
              }, (error, stackTrace) {
                FirebaseCrashlytics.instance.recordError(error, stackTrace);
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<Object>(
          future: getFriends(userUid),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());
            if (snapshot.data == 'none')
              return Center(
                  child: Text(AppLocalizations.of(context)
                      .translate("settingFriendsNone")));
            List<UserModel> users = snapshot.data;
            return ListView.builder(
              key: UniqueKey(),
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.account_box, size: 50),
                  title: Text(
                    users[index].nickName,
                    style: TextStyle(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    users[index].favoriteMusicCategory + ' lover',
                    style: TextStyle(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 30,
                    ),
                    onPressed: () async {
                      runZonedGuarded(() async {
                        await deleteFriend(users[index].uid);
                        setState(() {});
                      }, (error, stackTrace) {
                        FirebaseCrashlytics.instance
                            .recordError(error, stackTrace);
                      });
                    },
                  ),
                );
              },
            );
          }),
    );
  }
}
