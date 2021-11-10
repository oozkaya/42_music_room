import 'dart:async';

import 'package:MusicRoom42/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../../services/realtime_database/databases/users.dart';
import '../../ui/utils/toast/toast_utils.dart';
import '../../models/_models.dart';
import '../../app_localizations.dart';

class SettingProfileScreen extends StatefulWidget {
  @override
  _SettingProfileScreenState createState() => _SettingProfileScreenState();
}

class _SettingProfileScreenState extends State<SettingProfileScreen> {
  final auth = FirebaseAuth.instance;
  User authUser;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _email;
  TextEditingController _nickname;
  UserModel userData;
  bool hasEmailChanged = false;

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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    authUser = auth.currentUser;
    _email = TextEditingController(text: authUser.email);
    getUser(authUser.uid).then((UserModel u) {
      userData = u;
      _nickname = TextEditingController(text: u?.nickName);
      _selectedCategory = u?.favoriteMusicCategory;
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)
              .translate("settingProfileListTitle")),
        ),
        body: _loading
            ? Center(child: CircularProgressIndicator())
            : Align(
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
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate("privateData"),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: _email,
                            style: Theme.of(context).textTheme.bodyText2,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              var isValidEmail = RegExp(
                                      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                                  .hasMatch(value);
                              if (value.isEmpty || !isValidEmail)
                                return AppLocalizations.of(context)
                                    .translate("loginTxtErrorEmail");
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                hasEmailChanged = value != authUser.email;
                              });
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.alternate_email,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              labelText: AppLocalizations.of(context)
                                  .translate("loginTxtEmail"),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          hasEmailChanged
                              ? Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 5, 12, 0),
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .translate("emailUpdateInfo"),
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .fontSize,
                                    ),
                                  ),
                                )
                              : Container(),
                          SizedBox(height: 30),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate("publicData"),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(height: 15),
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
                            validator: (value) =>
                                value == null || value.length == 0
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
                            items:
                                _favoriteMusicCategories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 30),
                          RaisedButton(
                            child: Text(
                              AppLocalizations.of(context)
                                  .translate("settingProfilesave"),
                              style: Theme.of(context).textTheme.button,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            onPressed: () async {
                              runZonedGuarded(() async {
                                if (_formKey.currentState.validate() &&
                                    _selectedCategory != null) {
                                  FocusScope.of(context).unfocus();

                                  if (_email.text != authUser.email) {
                                    try {
                                      await AuthProvider()
                                          .updateProfileEmail(_email.text);
                                      ToastUtils.showCustomToast(
                                        context,
                                        AppLocalizations.of(context)
                                            .translate("emailSentToVerify"),
                                        level: ToastLevel.Info,
                                      );
                                    } catch (err) {
                                      ToastUtils.showCustomToast(
                                        context,
                                        err.message,
                                        level: ToastLevel.Error,
                                      );
                                      return;
                                    }
                                  }

                                  UserModel authUserModel =
                                      UserModel.from(userData);
                                  authUserModel.nickName = _nickname.text;
                                  authUserModel.favoriteMusicCategory =
                                      _selectedCategory;

                                  var res = await upsertUser(authUserModel);
                                  if (res == 'nickName exists') {
                                    ToastUtils.showCustomToast(
                                      context,
                                      AppLocalizations.of(context)
                                          .translate("loginTxtErrorNickname2"),
                                      level: ToastLevel.Error,
                                    );
                                  } else {
                                    try {
                                      await AuthProvider()
                                          .updateDisplayNameProfile(
                                              authUserModel.nickName);
                                    } catch (err) {
                                      ToastUtils.showCustomToast(
                                        context,
                                        err.message,
                                        level: ToastLevel.Error,
                                      );
                                      return;
                                    }

                                    ToastUtils.showCustomToast(
                                      context,
                                      AppLocalizations.of(context)
                                          .translate("settingProfilesaved"),
                                    );
                                    Navigator.of(context).pop();
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
              ));
  }
}
