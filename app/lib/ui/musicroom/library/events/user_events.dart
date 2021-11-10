import 'package:MusicRoom42/providers/spotify_player_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';

import '../../../../app_localizations.dart';
import '../../../../models/_models.dart';
import '../../../../providers/spotify_app_provider.dart';
import '../../../../services/firestore/collections/events_collection.dart';
import '../../subpages/event/event_screen.dart';
import '../../widgets/event_tile.dart';
import 'upsertEvent/upsert_event_settings_screen.dart';

class UserEvents extends StatefulWidget {
  final bool addTrackScreen;
  final Track track;
  final Function onAdd;

  UserEvents({this.addTrackScreen, this.track, this.onAdd});

  @override
  UserEventsState createState() => UserEventsState();
}

class UserEventsState extends State<UserEvents> {
  EventsCollection eventsCollection = EventsCollection();
  List<EventModel> eventsOwned = [];
  List<EventModel> eventWithRights = [];
  List<EventModel> eventsFollowed = [];
  bool isSearchBarDisplayed = false;
  final TextEditingController searchEventController = TextEditingController();
  String userId = FirebaseAuth.instance.currentUser.uid;

  Future<bool> _asyncInit() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    var writeOnly = widget.addTrackScreen;
    await Future.wait([
      eventsCollection
          .findByAdminId(currentUser.uid)
          .then((res) => eventsOwned = res),
      eventsCollection
          .findByUserId(currentUser.uid, writeOnly: writeOnly)
          .then((res) => eventWithRights = res),
      eventsCollection
          .findLikedByUserId(currentUser.uid, writeOnly: writeOnly)
          .then((res) => eventsFollowed = res),
    ]);

    var ownedAndFriendsIds = [];
    [...eventsOwned, ...eventWithRights]
        .forEach((e) => ownedAndFriendsIds.add(e.id));
    eventsFollowed.removeWhere((e) => ownedAndFriendsIds.indexOf(e.id) >= 0);
    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _groupTitle(String title) {
    if (title == null || title.length == 0) {
      return Container();
    }
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

  Future<void> addTrack(collabId) async {
    await EventsCollection().addTrack(context, collabId, widget.track);
    widget.onAdd();
    Navigator.pop(context);
  }

  Widget _searchEvent(BuildContext context) {
    return widget.addTrackScreen == true
        ? TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              autofocus: false,
              controller: searchEventController,
              decoration: InputDecoration(
                labelText:
                    AppLocalizations.of(context).translate("collabSearch"),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            suggestionsCallback: (pattern) async {
              if (pattern.length == 0) return null;
              var res = await EventsCollection()
                  .searchWritableByUserId(userId, pattern);
              return res.docs;
            },
            itemBuilder: (context, EventModel suggestion) {
              return EventTile(
                event: suggestion,
                onTap: widget.addTrackScreen == true
                    ? (_) => addTrack(suggestion.id)
                    : null,
                ancestorSetState: setState,
              );
            },
            onSuggestionSelected: (_collab) {
              searchEventController.clear();
            },
          )
        : Container();
  }

  Widget _createEvent(BuildContext context) {
    successCallback(eventId) async {
      if (widget.addTrackScreen != null) {
        addTrack(eventId);
      }
    }

    onTap(ctx) {
      Navigator.of(ctx)
          .push(MaterialPageRoute(
              builder: (_) => UpsertEventSettingsScreen(
                    event: null,
                    successCallback: successCallback,
                  )))
          .then((value) => setState(() {}));
    }

    return EventTile(
      name: AppLocalizations.of(context).translate('musicLibraryEventCreate'),
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
              Expanded(child: _createEvent(context)),
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
            child: isSearchBarDisplayed ? _searchEvent(context) : Container(),
          )
        ],
      );
    } else {
      return _createEvent(context);
    }
  }

  Widget _buildEventsGroup(SpotifyRemoteAppProvider spotifyAppProvider,
          String title, List<EventModel> events) =>
      Column(
        children: [
          _groupTitle(title),
          Column(
            key: UniqueKey(),
            children: events
                .map((evt) => EventTile(
                      event: evt,
                      onTap: (ctx) {
                        bool addTrackScreen = false;
                        try {
                          addTrackScreen =
                              (widget as dynamic).addTrackScreen == true;
                        } catch (_) {}

                        if (addTrackScreen != true) {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (ctx) => EventScreen(
                                        spotifyAppProvider.spotifyApi,
                                        evt.id,
                                        onLeaveEvent: () {
                                          setState(() {
                                            this.eventWithRights = this
                                                .eventWithRights
                                                .where((v) => v.id == evt.id)
                                                .toList();
                                            this.eventsFollowed = this
                                                .eventsFollowed
                                                .where((v) => v.id == evt.id)
                                                .toList();
                                          });
                                        },
                                      )))
                              .then((value) => setState(() {}));
                        } else {
                          EventsCollection()
                              .addTrack(context, evt.id, widget.track)
                              .then((res) {
                            widget.onAdd();
                            Navigator.pop(context);
                          });
                        }
                      },
                    ))
                .toList(),
          ),
        ],
      );

  Widget _buildEvents(
      BuildContext context, SpotifyRemoteAppProvider spotifyAppProvider) {
    Widget elem;

    if (eventsOwned?.isEmpty == true &&
        eventWithRights?.isEmpty == true &&
        eventsFollowed?.isEmpty == true) {
      elem = Column(
        children: [
          _buildTopBar(context),
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Text(
              AppLocalizations.of(context).translate('musicLibraryEventsEmpty'),
            ),
          ),
        ],
      );
    } else {
      elem = ListView(
        children: [
          SizedBox(height: 10),
          _buildTopBar(context),
          eventsOwned.isEmpty
              ? Container()
              : _buildEventsGroup(
                  spotifyAppProvider,
                  AppLocalizations.of(context)
                      .translate('musicLibraryMyEvents'),
                  eventsOwned),
          eventWithRights.isEmpty
              ? Container()
              : _buildEventsGroup(
                  spotifyAppProvider,
                  AppLocalizations.of(context)
                      .translate('musicLibraryEventsOfFriends'),
                  eventWithRights,
                ),
          eventsFollowed.isEmpty
              ? Container()
              : _buildEventsGroup(
                  spotifyAppProvider,
                  AppLocalizations.of(context)
                      .translate('musicLibraryEventsFollowed'),
                  eventsFollowed,
                ),
        ],
      );
    }
    return elem;
  }

  @override
  Widget build(BuildContext context) {
    final spotifyAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);
    return Selector<SpotifyPlayerProvider, String>(
        selector: (_, model) => model?.eventId,
        builder: (_, eventId, __) {
          if (eventId != null && widget.addTrackScreen != true)
            return EventScreen(spotifyAppProvider.spotifyApi, eventId);

          return FutureBuilder(
            future: _asyncInit(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return _buildEvents(context, spotifyAppProvider);
            },
          );
        });
  }
}
