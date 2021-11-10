import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../../../app_localizations.dart';
import '../../../models/_models.dart';
import '../../../services/realtime_database/databases/users.dart';
import '../../../ui/utils/toast/toast_utils.dart';

class FriendsSearch extends SearchDelegate<String> {
  void Function(void Function()) friendScreenSetState;
  String _selectedFriendUid;
  bool noResults = false;

  FriendsSearch(this.friendScreenSetState);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme =
        Theme.of(context).copyWith(textTheme: Theme.of(context).textTheme);
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            runZonedGuarded(() {
              _selectedFriendUid = null;
              if (query.isEmpty)
                close(context, null);
              else
                query = '';
            }, (error, stackTrace) {
              FirebaseCrashlytics.instance.recordError(error, stackTrace);
            });
          },
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          runZonedGuarded(() {
            close(context, null);
          }, (error, stackTrace) {
            FirebaseCrashlytics.instance.recordError(error, stackTrace);
          });
        },
      );

  @override
  Widget buildResults(BuildContext context) => _selectedFriendUid == null
      ? buildSuggestions(context)
      : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle, size: 200),
              SizedBox(height: 10),
              Text(query, style: TextStyle(fontSize: 50)),
              SizedBox(height: 30),
              RaisedButton(
                child: Text(
                  AppLocalizations.of(context).translate("settingFriendsAdd"),
                  style: TextStyle(fontSize: 40),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                onPressed: () async {
                  runZonedGuarded(() async {
                    if (_selectedFriendUid != null) {
                      String userUid = FirebaseAuth.instance.currentUser.uid;
                      if (userUid == _selectedFriendUid) {
                        ToastUtils.showCustomToast(
                            context,
                            AppLocalizations.of(context)
                                .translate("settingFriendsUserHimself"));
                      } else {
                        bool success = await addFriend(_selectedFriendUid);
                        if (success == true) {
                          friendScreenSetState(() {});
                          ToastUtils.showCustomToast(
                              context,
                              AppLocalizations.of(context)
                                  .translate("settingFriendsAdded"));
                        } else {
                          ToastUtils.showCustomToast(
                              context,
                              AppLocalizations.of(context)
                                  .translate("settingFriendsNotFound"));
                        }
                      }
                    } else {
                      ToastUtils.showCustomToast(
                          context,
                          AppLocalizations.of(context)
                              .translate("settingFriendsNotFound"));
                    }
                  }, (error, stackTrace) {
                    FirebaseCrashlytics.instance.recordError(error, stackTrace);
                  });
                },
              ),
            ],
          ),
        );

  @override
  Widget buildSuggestions(BuildContext context) {
    return query.length < 3
        ? Container()
        : FutureBuilder(
            future: searchUsers(query),
            builder: (ctx, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              if (snapshot.data == 'none') {
                return StatefulBuilder(builder: (_, setState) {
                  setState(() {
                    noResults = true;
                  });
                  return Center(
                      child: Text(AppLocalizations.of(context)
                          .translate("settingFriendsNoResults")));
                });
              }
              List<UserModel> users = snapshot.data;
              return StatefulBuilder(builder: (_, setState) {
                setState(() {
                  noResults = false;
                });
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (__, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.account_box,
                          size: 50,
                        ),
                        title: Text(
                          users[index].nickName,
                          style: TextStyle(fontSize: 20),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward,
                          size: 30,
                        ),
                        onTap: () {
                          query = users[index].nickName;
                          setState(() {
                            _selectedFriendUid = users[index].uid;
                          });
                          showResults(context);
                        },
                      ),
                    );
                  },
                );
              });
            },
          );
  }
}
