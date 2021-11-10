import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../../../../../app_localizations.dart';
import '../../../../../../../models/_models.dart';
import '../../../../../../../services/realtime_database/databases/users.dart';
import '../../../../../widgets/collab_user_rights_tile.dart';

class UserRights extends StatefulWidget {
  final Collab editingCollab;
  final List<UserModel> userFriends;
  final Function updateUserRights;
  final GlobalKey<FormBuilderState> formKey;

  UserRights(
      {this.editingCollab,
      this.userFriends,
      this.updateUserRights,
      this.formKey});

  @override
  _UserRightsState createState() => _UserRightsState();
}

class _UserRightsState extends State<UserRights> {
  final TextEditingController searchFriendController = TextEditingController();

  CollabRights collabRights;
  List<UserModel> collabUsers;

  @override
  void dispose() {
    searchFriendController.dispose();
    super.dispose();
  }

  Future<bool> _asyncInit() async {
    collabRights = widget.editingCollab.rights;
    var collabUsersIds = widget.editingCollab.rights.usersRights.keys.toList();
    collabUsers = await getUsersFromUids(collabUsersIds);
    return true;
  }

  Widget _buildUserRights(BuildContext context) {
    List<UserModel> suggestionsList = [];
    widget.userFriends?.forEach((friend) {
      var existingFriend = collabUsers
          ?.firstWhere((user) => friend.uid == user.uid, orElse: () => null);
      if (existingFriend == null) {
        suggestionsList.add(friend);
      }
    });
    var shouldDisplaySearchInput = widget.userFriends != null &&
        widget.userFriends.length > 0 &&
        suggestionsList.length > 0;
    var searchInputFallbackText = widget.userFriends == null
        ? ''
        : widget.userFriends.length == 0
            ? AppLocalizations.of(context).translate("userRightsNoFriend")
            : AppLocalizations.of(context)
                .translate("userRightsAllFriendsAdded");

    return FormBuilderField(
      name: "userRights",
      initialValue: collabRights.usersRights,
      builder: (FormFieldState<dynamic> field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText:
                AppLocalizations.of(context).translate("userRightsManagement"),
            contentPadding: EdgeInsets.only(top: 10.0, bottom: 0.0),
            border: InputBorder.none,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              shouldDisplaySearchInput == false
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: Text(
                        searchInputFallbackText,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    )
                  : Form(
                      child: TypeAheadField(
                        textFieldConfiguration: TextFieldConfiguration(
                          autofocus: false,
                          controller: searchFriendController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)
                                .translate("collabAddFriend"),
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        suggestionsCallback: (pattern) {
                          return pattern.length == 0
                              ? null
                              : suggestionsList.where(
                                  (element) => [element.nickName].any(
                                      (String value) =>
                                          value?.contains(pattern)),
                                );
                        },
                        direction: AxisDirection.up,
                        itemBuilder: (context, UserModel suggestion) {
                          return ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add),
                              ],
                            ),
                            title: Text(suggestion.nickName),
                          );
                        },
                        onSuggestionSelected: (friend) {
                          searchFriendController.clear();
                          widget.updateUserRights(friend.uid,
                              CollabUserRights(read: true, write: false));
                        },
                      ),
                    ),
              ...collabUsers?.map((user) => CollabUserRightsTile(
                    userData: user,
                    userRights: collabRights.usersRights[user.uid],
                    updateUserRights: widget.updateUserRights,
                  )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _asyncInit(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          return _buildUserRights(context);
        }
      },
    );
  }
}
