import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:pagination_view/pagination_view.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../../utils/calculateDistance.dart';
import '../../../../app_localizations.dart';
import '../../../../constants/spotify_color_scheme.dart';
import '../../../../models/_models.dart';
import '../../../../providers/spotify_app_provider.dart';
import '../../../../providers/spotify_player_provider.dart';
import '../../../../ui/musicroom/library/events/user_events.dart';
import '../../../../services/currentLocation/initLocation.dart';
import '../../../../services/realtime_database/databases/events.dart';
import '../../../../services/firestore/collections/events_collection.dart';
import '../../../../services/realtime_database/databases/event_database.dart';
import '../../../../utils/getImagePalette.dart';
import '../../subpages/event/event_settings.dart' as EvtSettings;
import '../../widgets/header_image_medium.dart';
import '../../widgets/track_tile.dart';
import 'event_like.dart';

class EventScreen extends StatefulWidget {
  final SpotifyApi spotifyApi;
  final String eventId;
  final Function onLeaveEvent;

  EventScreen(
    this.spotifyApi,
    this.eventId, {
    this.onLeaveEvent,
  });

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  SpotifyPlayerProvider playerProvider;
  UserEventsState userEventsState;
  Uint8List eventImageBytes;
  Color backgroundColor;
  bool sortTracks = false;
  bool showMenu = true;

  int page;
  GlobalKey<PaginationViewState> key;

  StreamSubscription locationStreamSubscription;
  Location location;
  LocationData currentLocation;
  double distanceKmFromEvent;

  getEventImage(EventModel event) {
    if (event != null && event.tracks != null && event.tracks.length > 0) {
      EventTrack track = event.tracks.first;
      if (track.track != null && track.track.album != null) {
        AlbumSimple album = track.track.album;
        if (album.images != null && album.images.length > 0) {
          return album.images[1].url;
        }
      }
    }
    return null;
  }

  @override
  void initState() {
    playerProvider = Provider.of<SpotifyPlayerProvider>(context, listen: false);
    userEventsState = context.findAncestorStateOfType<UserEventsState>();
    page = -1;
    key = GlobalKey<PaginationViewState>();
    initLocation().then((_location) {
      location = _location;
      locationStreamSubscription =
          location.onLocationChanged.listen((LocationData _currentLocation) {
        setState(() => currentLocation = _currentLocation);
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    locationStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SpotifyRemoteAppProvider spotifyAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);

    String _getEventDescription(EventModel event) {
      final Map<String, dynamic> translateValues = {
        'owner': event.adminUsername
      };
      return AppLocalizations.of(context)
          .translate("musicEventDescription", translateValues);
    }

    List<TrackTile> getTrackList(EventModel event, double distanceKmFromEvent) {
      List<TrackTile> tiles = List();
      if (event == null || event.tracks == null || event.tracks.isEmpty)
        return tiles;
      event.tracks.asMap().forEach((index, item) {
        if (item.track != null) {
          tiles.add(
            TrackTile(
              event,
              item,
              TypeSearch.playlist,
              index: index,
              showImage: true,
              key: ValueKey(item.track),
              draggable: sortTracks,
              isEvent: true,
              onDelete: () {
                EventsCollection().deleteTrack(widget.eventId, item);
              },
              distanceKmFromEvent: distanceKmFromEvent,
            ),
          );
        }
      });
      return tiles;
    }

    String _getRightsDescription(EventModel event) {
      var uid = FirebaseAuth.instance.currentUser.uid;
      var isAdmin = event.adminUserId == uid;
      if (isAdmin) return "Admin";
      String rights = '';
      var usersRights = event.usersRights ?? {};
      var canRead = event.isPublic || usersRights[uid]?.read == true;
      var canVote = event.isPublic || usersRights[uid]?.vote == true;
      var canEdit = usersRights[uid]?.edit == true;
      if (canRead) rights += 'Read';
      if (canVote) rights += ' Vote';
      if (canEdit) rights += ' Edit';
      return rights;
    }

    HeaderImageMedium getHeader(
        dynamic event, Color bgColor, double distanceKmFromEvent) {
      var uid = FirebaseAuth.instance.currentUser.uid;
      var isAdmin = event.adminUserId == uid;
      return HeaderImageMedium(
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.mediumGray,
        imageBytes: eventImageBytes,
        trackContainer: event,
        itemUri: event.id,
        title: event.name,
        subtitle: _getEventDescription(event),
        subtitle2: _getRightsDescription(event),
        distanceKmFromEvent: distanceKmFromEvent,
        disableButton: isAdmin == false || playerProvider.eventId == null,
      );
    }

    Future<bool> refreshHeaderPalette(dynamic event) async {
      var imageUrl = getEventImage(event);
      ImagePalette palette = await getImagePalette(imgUrl: imageUrl);
      backgroundColor = palette.favorite;
      eventImageBytes = palette.imageBytes;
      return true;
    }

    FutureBuilder headerBuilder(dynamic event, double distanceKmFromEvent) {
      return FutureBuilder(
        future: refreshHeaderPalette(event),
        builder: (BuildContext context, snapshot) => getHeader(
          event,
          snapshot.hasData
              ? backgroundColor
              : Theme.of(context).colorScheme.mediumGray,
          distanceKmFromEvent,
        ),
      );
    }

    bool checkRestrictions(EventSettings settings, double distance) {
      if (settings?.isTimeRestrictionEnabled == true) {
        var now = DateTime.now();
        var startDate = settings?.voteRestrictions?.startDate;
        var endDate = settings?.voteRestrictions?.endDate;
        var hasNotStartedYet = startDate != null && now.isBefore(startDate);
        var isFinished = endDate != null && now.isAfter(endDate);
        if (hasNotStartedYet || isFinished) return false;
      }
      if (settings?.isLocationRestrictionEnabled == true) {
        if (distance == null || distance > 0.2) return false;
      }
      return true;
    }

    Widget buildBody(EventModel elem) {
      if (elem.settings?.isLocationRestrictionEnabled == true) {
        var eventLatLng = elem.settings.voteRestrictions.locationLatLng;
        distanceKmFromEvent = calculateDistance(
          currentLocation?.latitude,
          currentLocation?.longitude,
          eventLatLng?.latitude,
          eventLatLng?.longitude,
        );
      }

      bool canAccess = checkRestrictions(elem.settings, distanceKmFromEvent);
      bool canJoin = canAccess && playerProvider.eventId == null;
      bool canLeave = playerProvider.eventId != null;

      Widget actionButton = Padding(
        padding: const EdgeInsets.fromLTRB(80, 10, 80, 10),
        child: canJoin || canLeave
            ? RaisedButton(
                child: Text(
                  playerProvider.eventId != null ? 'Leave' : 'Join',
                  style: TextStyle(
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                textColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                onPressed: () async {
                  runZonedGuarded(() async {
                    String eventId = playerProvider.eventId;
                    eventId != null
                        ? await kickFromEvent(playerProvider, eventId)
                        : await joinEvent(playerProvider, elem.id, context);
                    userEventsState?.setState(() {});
                  }, (error, stackTrace) {
                    FirebaseCrashlytics.instance.recordError(error, stackTrace);
                  });
                },
              )
            : Container(),
      );

      if (elem.tracks != null && elem.tracks.length > 0) {
        if (sortTracks == true) {
          return ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  EventTrack tmp = elem.tracks.removeAt(oldIndex);
                  if (newIndex > oldIndex) {
                    newIndex--;
                  }
                  elem.tracks.insert(newIndex, tmp);
                  EventsCollection().updateEvent(widget.eventId, elem.toJson());
                });
              },
              header: headerBuilder(elem, distanceKmFromEvent),
              children: getTrackList(elem, distanceKmFromEvent));
        } else {
          return ListView(
            children: [
              headerBuilder(elem, distanceKmFromEvent),
              ...getTrackList(elem, distanceKmFromEvent),
              // SizedBox(height: 10),
              actionButton,
              // SizedBox(height: 10)
            ],
          );
        }
      } else {
        return Column(
          children: [
            headerBuilder(elem, distanceKmFromEvent),
            Spacer(),
            Text(
              AppLocalizations.of(context).translate("musicEventNoSongs"),
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            actionButton,
            Spacer(),
          ],
        );
      }
    }

    return StreamBuilder(
        key: ValueKey(widget.eventId),
        stream: EventDatabase().getQuery(widget.eventId).onValue,
        builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.data.snapshot.value == null) {
              if (playerProvider.eventId == null) Navigator.of(context).pop();
              return Container();
            }
            EventModel elem = EventModel.fromJson(
                jsonDecode(jsonEncode(snapshot.data.snapshot.value)),
                widget.eventId);
            return Scaffold(
                extendBodyBehindAppBar: false,
                appBar: AppBar(
                  title: Text(
                    elem.name,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  centerTitle: true,
                  actions: <Widget>[
                    EventLike(elem),
                    EvtSettings.EventSettings(
                      context,
                      elem,
                      spotifyAppProvider,
                      hasTracks: elem.tracks != null && elem.tracks.length > 0,
                      onSortEdit: () {
                        setState(() => this.sortTracks = !this.sortTracks);
                      },
                    ),
                  ],
                ),
                body: Container(
                  child: buildBody(elem),
                ));
          }
        });
  }
}
