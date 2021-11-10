import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../../../../../../app_localizations.dart';
import '../../../../../../../models/_models.dart';
import '../../../../../../../services/realtime_database/databases/users.dart';
import '../../../../../widgets/event_user_rights_tile.dart';

class EventUserRights extends StatefulWidget {
  final EventModel editingEvent;
  final List<UserModel> userFriends;
  final Function updateUserRights;

  EventUserRights({
    this.editingEvent,
    this.userFriends,
    this.updateUserRights,
  });

  @override
  _UserRightsState createState() => _UserRightsState();
}

class _UserRightsState extends State<EventUserRights> {
  final TextEditingController searchFriendController = TextEditingController();

  Map<String, EventUsersRights> usersRights;
  List<UserModel> eventUsers;

  @override
  void dispose() {
    searchFriendController.dispose();
    super.dispose();
  }

  Future<bool> _asyncInit() async {
    usersRights = widget.editingEvent.usersRights;
    var eventUsersIds = widget.editingEvent.usersRights.keys.toList();
    eventUsers = await getUsersFromUids(eventUsersIds);
    return true;
  }

  Widget _buildUserRights(BuildContext context) {
    List<UserModel> suggestionsList = [];
    widget.userFriends?.forEach((friend) {
      var existingFriend = eventUsers
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(75, 0, 20, 0),
      child: FormBuilderField(
        name: "userRights",
        initialValue: usersRights,
        builder: (FormFieldState<dynamic> field) {
          return Column(
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
                            contentPadding: EdgeInsets.zero,
                            labelText: AppLocalizations.of(context)
                                .translate("eventAddFriend"),
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            prefixIcon: Icon(Icons.search),
                            prefixIconConstraints: BoxConstraints(
                              minWidth: 35,
                              minHeight: 35,
                            ),
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
                          widget.updateUserRights(
                            friend.uid,
                            EventUsersRights(
                              read: true,
                              edit: false,
                              vote: false,
                            ),
                          );
                        },
                      ),
                    ),
              ...eventUsers?.map(
                (user) => EventUserRightsTile(
                  userData: user,
                  userRights: usersRights[user.uid],
                  updateUserRights: widget.updateUserRights,
                ),
              ),
            ],
          );
        },
      ),
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
