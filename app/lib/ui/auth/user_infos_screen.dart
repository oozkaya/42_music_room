import 'dart:async';

import 'package:MusicRoom42/providers/auth_provider.dart';
import 'package:MusicRoom42/ui/musicroom/music_room_screen.dart';
import 'package:MusicRoom42/ui/utils/toast/toast_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../../app_localizations.dart';
import '../../models/_models.dart';
import '../../services/realtime_database/databases/users.dart';

class UserInfosScreen extends StatefulWidget {
  final String userUid;

  UserInfosScreen(this.userUid);

  @override
  _UserInfosScreenState createState() => _UserInfosScreenState();
}

class _UserInfosScreenState extends State<UserInfosScreen> {
  final auth = FirebaseAuth.instance;
  User user;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nickname;
  List<String> _favoriteMusicCategories = <String>[
    'Rap',
    'Electro',
    'Rock',
    'Jazz',
    "R'n'b",
    'Pop',
    'Classic',
  ];
  String _selectedCategory;

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    _nickname = TextEditingController(text: '');
    _selectedCategory = null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Align(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    Icon(Icons.account_circle, size: 80),
                    Text(
                      AppLocalizations.of(context)
                          .translate("settingProfileListTitle"),
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: _nickname,
                      style: Theme.of(context).textTheme.bodyText2,
                      validator: (value) => value.isEmpty
                          ? AppLocalizations.of(context)
                              .translate("loginTxtErrorNickname")
                          : null,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.emoji_people,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        labelText: AppLocalizations.of(context)
                            .translate("loginTxtNickname"),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField(
                      hint: Text("Select"),
                      value: _selectedCategory,
                      validator: (value) => value == null || value.length == 0
                          ? AppLocalizations.of(context)
                              .translate("loginTxtErrorGenre")
                          : null,
                      onChanged: (String value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.music_note,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        labelText: AppLocalizations.of(context)
                            .translate("loginTxtFavoriteCategory"),
                        border: OutlineInputBorder(),
                      ),
                      items: _favoriteMusicCategories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 30),
                    RaisedButton(
                      child: Text(
                        AppLocalizations.of(context).translate("loginNext"),
                        style: Theme.of(context).textTheme.button,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      onPressed: () async {
                        runZonedGuarded(() async {
                          if (_formKey.currentState.validate()) {
                            FocusScope.of(context).unfocus();

                            UserModel userModel = new UserModel(
                                uid: widget.userUid,
                                nickName: _nickname.text,
                                favoriteMusicCategory: _selectedCategory);

                            var res = await upsertUser(userModel);
                            if (res == 'nickName exists') {
                              ToastUtils.showCustomToast(
                                context,
                                AppLocalizations.of(context)
                                    .translate("loginTxtErrorNickname2"),
                                level: ToastLevel.Error,
                              );
                              return;
                            } else {
                              try {
                                await AuthProvider().updateDisplayNameProfile(
                                    userModel.nickName);
                              } catch (err) {
                                ToastUtils.showCustomToast(
                                  context,
                                  err.message,
                                  level: ToastLevel.Error,
                                );
                                return;
                              }
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (_) => MusicRoomScreen()));
                            }
                          }
                        }, (error, stackTrace) {
                          FirebaseCrashlytics.instance
                              .recordError(error, stackTrace);
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
