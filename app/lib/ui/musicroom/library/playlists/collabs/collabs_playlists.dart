import 'package:MusicRoom42/services/firestore/collections/collabs_collection.dart';
import 'package:MusicRoom42/ui/musicroom/library/playlists/collabs/upsertCollabSettings/upsert_collab_settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:spotify/spotify.dart';

import '../../../../../app_localizations.dart';
import '../../../../../models/_models.dart';
import '../../../widgets/collab_tile.dart';

class CollabsPlaylists extends StatefulWidget {
  final bool addTrackScreen;
  final Track track;
  final Function onAdd;

  CollabsPlaylists({this.addTrackScreen, this.track, this.onAdd});

  @override
  _CollabsPlaylistsState createState() => _CollabsPlaylistsState();
}

class _CollabsPlaylistsState extends State<CollabsPlaylists> {
  CollabsCollection collabsCollection = CollabsCollection();
  List<Collab> collabsOwned = [];
  List<Collab> collabsOfFriends = [];
  List<Collab> collabsLiked = [];
  bool isSearchBarDisplayed = false;
  final TextEditingController searchCollabController = TextEditingController();
  String userId = FirebaseAuth.instance.currentUser.uid;

  Future<bool> _asyncInit() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    var writeOnly = widget.addTrackScreen;
    await Future.wait([
      collabsCollection
          .findByAdminId(currentUser.uid)
          .then((res) => collabsOwned = res),
      collabsCollection
          .findByUserId(currentUser.uid, writeOnly: writeOnly)
          .then((res) => collabsOfFriends = res),
      collabsCollection
          .findLikedByUserId(currentUser.uid, writeOnly: writeOnly)
          .then((res) => collabsLiked = res),
    ]);

    var ownedAndFriendsIds = [];
    [...collabsOwned, ...collabsOfFriends]
        .forEach((c) => ownedAndFriendsIds.add(c.id));
    collabsLiked.removeWhere((c) => ownedAndFriendsIds.indexOf(c.id) >= 0);
    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> addTrack(collabId) async {
    await CollabsCollection().addTrack(context, collabId, widget.track);
    widget.onAdd();
    Navigator.pop(context);
  }

  Widget _groupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _searchCollab(BuildContext context) {
    return widget.addTrackScreen == true
        ? TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              autofocus: false,
              controller: searchCollabController,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).translate("collabSearch"),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            // direction: AxisDirection.up,
            suggestionsCallback: (pattern) async {
              if (pattern.length == 0) return null;
              var res = await CollabsCollection()
                  .searchWritableByUserId(userId, pattern);
              return res.docs;
            },
            itemBuilder: (context, Collab suggestion) {
              return CollabTile(
                collab: suggestion,
                onTap: widget.addTrackScreen == true
                    ? (_) => addTrack(suggestion.id)
                    : null,
                ancestorSetState: setState,
              );
            },
            onSuggestionSelected: (_collab) {
              searchCollabController.clear();
            },
          )
        : Container();
  }

  Widget _createCollab(BuildContext context) {
    successCallback(collabId) async {
      if (widget.addTrackScreen != null) {
        addTrack(collabId);
      }
    }

    onTap(ctx) {
      Navigator.of(ctx)
          .push(MaterialPageRoute(
              builder: (_) => UpsertCollabSettingsScreen(
                    collab: null,
                    successCallback: successCallback,
                  )))
          .then((value) => setState(() {}));
    }

    return CollabTile(
      name: AppLocalizations.of(context).translate('musicLibraryCollabCreate'),
      leading: Icon(Icons.add, size: 55.0),
      onTap: onTap,
      ancestorSetState: setState,
    );
  }

  Widget _searchIcon(BuildContext context) => ListTile(
        title: Text(
            AppLocalizations.of(context).translate('musicLibraryEventSearch'),
            textAlign: TextAlign.right),
        trailing: Icon(Icons.search, size: 40.0),
        onTap: () =>
            setState(() => isSearchBarDisplayed = !isSearchBarDisplayed),
      );

  Widget _buildTopBar(BuildContext context) {
    if (widget.addTrackScreen == true) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _createCollab(context)),
              Container(height: 40, child: VerticalDivider(color: Colors.grey)),
              Expanded(child: _searchIcon(context)),
            ],
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  child: child,
                  position: Tween<Offset>(
                          begin: Offset(0, -1.0), end: Offset(0.0, 0.0))
                      .animate(animation),
                ),
              );
            },
            child: isSearchBarDisplayed ? _searchCollab(context) : Container(),
          )
        ],
      );
    } else {
      return _createCollab(context);
    }
  }

  Widget _buildCollabsGroup(String title, List<Collab> collabs) => Column(
        children: [
          _groupTitle(title),
          Column(
            key: UniqueKey(),
            children: collabs
                .map((_collab) => CollabTile(
                      collab: _collab,
                      onTap: widget.addTrackScreen == true
                          ? (_) => addTrack(_collab.id)
                          : null,
                      ancestorSetState: setState,
                    ))
                .toList(),
          ),
        ],
      );

  Widget _buildCollabs(BuildContext context) {
    if (collabsOwned.isEmpty &&
        collabsOfFriends.isEmpty &&
        collabsLiked.isEmpty) {
      return Column(
        children: [
          _createCollab(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Text(
              AppLocalizations.of(context)
                  .translate('musicLibraryCollabsEmpty'),
            ),
          ),
        ],
      );
    }
    return ListView(
      children: [
        SizedBox(height: 10),
        _buildTopBar(context),
        collabsOwned.isEmpty
            ? Container()
            : _buildCollabsGroup(
                AppLocalizations.of(context)
                    .translate('musicLibraryCollabsOwned'),
                collabsOwned,
              ),
        collabsOfFriends.isEmpty
            ? Container()
            : _buildCollabsGroup(
                AppLocalizations.of(context)
                    .translate('musicLibraryCollabsOfFriends'),
                collabsOfFriends,
              ),
        collabsLiked.isEmpty
            ? Container()
            : _buildCollabsGroup(
                AppLocalizations.of(context)
                    .translate('musicLibraryCollabsLiked'),
                collabsLiked,
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _asyncInit(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return _buildCollabs(context);
          }
        });
  }
}
