import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:MusicRoom42/models/_models.dart';
import 'package:MusicRoom42/services/realtime_database/databases/users.dart';
import 'package:MusicRoom42/services/spotify/player_basics.dart' as Player;
import 'package:MusicRoom42/services/firestore/collections/events_collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
import 'package:spotify/spotify.dart' as SpotifyDart;
import 'package:spotify_sdk/models/player_context.dart';
import 'package:spotify_sdk/models/player_restrictions.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/models/track.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import '../providers/spotify_app_provider.dart';
import '../services/realtime_database/databases/common.dart';
import '../services/realtime_database/databases/events.dart'
    hide sendPosition, sendIsPaused;
import '../services/realtime_database/databases/sessions.dart'
    hide sendPosition, sendIsPaused;
import '../services/spotify/api/track.dart' as ApiTrack;
import '../services/spotify/open_item.dart';
import '../services/spotify/player_suffle_mode.dart';
import '../services/spotify/player_state.dart';
import '../utils/getImagePalette.dart';

import '../utils/logger.dart';

class SpotifyPlayerProvider extends ChangeNotifier {
  BuildContext buildContext;
  StreamSubscription contextListener;
  StreamSubscription stateListener;
  String contextTitle;
  String contextSubtitle;
  Track track;
  int playbackPosition;
  bool isPaused = false;
  PlayerRestrictions playbackRestrictions;
  bool isShuffling = false;
  bool isLiked = false;
  Color backgroundColor;
  Timer timer;
  PlayerContext playerContext;
  SpotifyRemoteAppProvider remoteAppProvider;
  List<SpotifyDart.Track> _trackHistory = [];
  List<SpotifyDart.Track> _queue = [];

  String sessionId;
  bool isSessionAdmin = false;
  String senderUid;
  bool isSessionMaster = false;
  List<String> sessionMembers;
  StreamSubscription sessionListener;
  StreamSubscription userSessionIdListener;

  String eventId;
  bool isEventAdmin = false;
  List<EventTrack> eventTracks;
  StreamSubscription eventListener;
  StreamSubscription userEventIdListener;

  Track getTrack() => track;
  String getTrackUri() => track?.uri;
  String getTrackId() => track?.uri != null
      ? track.uri.substring(track.uri.lastIndexOf(':') + 1)
      : null;

  List<SpotifyDart.Track> get trackHistory => _trackHistory;
  List<SpotifyDart.Track> get queue => _queue;

  SpotifyPlayerProvider(this.buildContext);

  @override
  void dispose() {
    close();
    super.dispose();
  }

  Future<void> init(SpotifyRemoteAppProvider remoteAppProvider) async {
    setRemoteAppProvider(remoteAppProvider);
    getPlayerState().then((playerState) {
      track = playerState.track;
      playbackPosition = playerState.playbackPosition;
      isPaused = playerState.isPaused;
      playbackRestrictions = playerState.playbackRestrictions;
      isShuffling = playerState.playbackOptions.isShuffling;

      contextListener = SpotifySdk.subscribePlayerContext()
          .listen((playerContext) => setPlayerContext(playerContext));
      stateListener =
          SpotifySdk.subscribePlayerState().listen((playerState) async {
        bool canSendSession = sessionId != null &&
            isSessionMaster &&
            track?.uri != playerState?.track?.uri;
        bool canSet = (eventId == null && sessionId == null) ||
            (sessionId != null && isSessionMaster) ||
            (isEventAdmin && track?.uri != playerState?.track?.uri);

        if (canSendSession) {
          await sendPosition(this, playerState.playbackPosition);
          await sendTrackUri(sessionId, playerState.track.uri);
        }
        if (canSet) await setPlayerState(playerState);
      });
      userSessionIdListener = createUserSessionListener();
      userEventIdListener = createUserEventListener();
    });
  }

  void close() {
    contextListener?.cancel();
    stateListener?.cancel();
    sessionListener?.cancel();
    userSessionIdListener?.cancel();
    userEventIdListener.cancel();
  }

  StreamSubscription createUserSessionListener() {
    return onUserSessionChanged().listen(
      (event) {
        var sessionId = event.snapshot.value;
        if (sessionId == null) {
          setSessionId(null);
          setSenderUid(null);
          setIsSessionMaster(false);
          setSessionMembers(null);
          sessionListener?.cancel();
        } else {
          if (eventId != null) kickFromEvent(this, eventId);
          sessionListener = createSessionListener(sessionId);
        }
      },
      onDone: () =>
          CustomLogger().i('[createUserSessionListener] user session changed'),
      onError: (e) => CustomLogger().e(e.toString()),
    );
  }

  StreamSubscription createSessionListener(String sessionId) {
    return onSessionChanged(sessionId).listen(
      (event) async {
        if (event.snapshot.value != null) {
          var session = SessionModel.fromJson(event.snapshot.value);
          String userUid = FirebaseAuth.instance.currentUser.uid;
          bool isSender = userUid == session.senderUid;

          setIsSessionAdmin(userUid == session.adminUid);
          setSenderUid(session.senderUid);
          setSessionMembers(session.members);
          setIsSessionMaster(userUid == session.masterUid);

          await refreshSessionPlaybackPosition(session, isSender);

          if (!isSender && track?.uri != session.trackUri) {
            await Player.play(spotifyUri: session.trackUri, asRadio: true)
                .then((_) async {
              await Player.pause();

              bool isCompleted = false;
              while (!isCompleted)
                await Future.delayed(Duration(milliseconds: 500), () {
                  getPlayerState().then((state) {
                    if (state.track == null) return;
                    setTrack(state.track);
                    isCompleted = true;
                  });
                });
            });
          }

          if (!isSender) {
            session.isPaused ? await Player.pause() : await Player.resume();
            setIsPaused(session.isPaused);
          }

          setSessionId(sessionId);
        }
      },
      onDone: () => CustomLogger().i('[createSessionListener] session changed'),
      onError: (e) => CustomLogger().e(e.toString()),
    );
  }

  Future<void> refreshSessionPlaybackPosition(
      SessionModel session, bool isSender) async {
    if (playbackPosition != session.playbackPosition && !isSender) {
      int position = session.playbackPosition ?? 0;
      int positionStartTime = session.playbackPositionStartTime ?? 0;
      int pos;
      if (sessionId == null && !session.isPaused)
        pos = position +
            (DateTime.now().millisecondsSinceEpoch - positionStartTime);
      else
        pos = position;

      if (pos < 0) pos = position;
      setPosition(pos);
      await Player.seekTo(pos);
    }
  }

  StreamSubscription createUserEventListener() {
    return onUserEventChanged().listen(
      (event) {
        var eventId = event.snapshot.value;
        if (eventId == null) {
          setEventId(null);
          setEventTracks(null);
          setIsEventAdmin(false);
          setIsPaused(true);
          eventListener?.cancel();
        } else {
          String userUid = FirebaseAuth.instance.currentUser.uid;
          if (sessionId != null) kickFromSession(userUid, sessionId);
          eventListener = createEventListener(eventId);
        }
      },
      onDone: () =>
          CustomLogger().i('[createUserEventListener] user session changed'),
      onError: (e) => CustomLogger().e(e.toString()),
    );
  }

  StreamSubscription createEventListener(String evtId) {
    return onEventChanged(evtId).listen(
      (evt) async {
        if (evt.snapshot.value != null) {
          var eventJson = jsonDecode(jsonEncode(evt.snapshot.value));
          var event = EventModel.fromJson(eventJson, evtId);
          if (event.tracks == null || event.tracks.isEmpty)
            return setEventTracks(null);

          String userUid = FirebaseAuth.instance.currentUser.uid;
          bool isSameFirstTrack =
              eventTracks?.first?.track?.uri == event.tracks?.first?.track?.uri;
          setIsEventAdmin(userUid == event.adminUserId);
          if (isEventAdmin) handleUpvotes(event.tracks);
          if (isEventAdmin && isSameFirstTrack) return;

          if (!isSameFirstTrack) {
            setEventTracks(event.tracks);
            if (isEventAdmin) {
              setEventId(event.id);
              return;
            }

            await Player.play(spotifyUri: event.tracks.first.track.uri)
                .then((_) async {
              await Player.pause();

              bool isCompleted = false;
              while (!isCompleted)
                await Future.delayed(Duration(milliseconds: 500), () {
                  getPlayerState().then((state) {
                    if (state.track == null) return;
                    setTrack(state.track);
                    isCompleted = true;
                  });
                });
            });
          }

          await refreshEventPlaybackPosition(event);
          if (isPaused != event.isPaused) setIsPaused(event.isPaused);
          if (eventId != event.id) setEventId(event.id);
        } else
          await kickFromEvent(this, evtId);
      },
      onDone: () => CustomLogger().i('[createSessionListener] session changed'),
      onError: (e) => CustomLogger().e(e.toString()),
    );
  }

  Future<void> refreshEventPlaybackPosition(EventModel event) async {
    if (playbackPosition != event.playbackPosition) {
      int position = event.playbackPosition ?? 0;
      int positionStartTime = event.playbackPositionStartTime ?? 0;
      int pos;
      if (eventId == null && !event.isPaused)
        pos = position +
            (DateTime.now().millisecondsSinceEpoch - positionStartTime);
      else
        pos = position;

      if (pos < 0) pos = position;
      setPosition(pos);
    }
  }

  bool isSameTracks(List<EventTrack> ts) {
    for (var i = 0; i < ts.length; i++) {
      if (eventTracks.elementAt(i).track.uri != ts.elementAt(i).track.uri)
        return false;
    }
    return true;
  }

  void handleUpvotes(List<EventTrack> ts) {
    if (eventTracks == null || ts == null || isSameTracks(ts)) return;

    setEventTracks(ts);
    sendPosition(this, playbackPosition);

    List<SpotifyDart.Track> tracks = ts.map((t) => t.track).toList();
    setQueue([]);
    tracks.removeAt(0);
    addListToLocalQueue(this, tracks, null, false);
  }

  Future<void> getBackgroundColor(Uint8List img) async {
    var imagePalette = await getImagePalette(imgUint8List: img);
    backgroundColor = imagePalette.favorite;
    notifyListeners();
  }

  void setPlayerContext(PlayerContext context) {
    contextTitle = context.title;
    contextSubtitle = context.subtitle;
    notifyListeners();
  }

  Future<void> setPlayerState(PlayerState state) async {
    stopTimer();
    if (state?.track?.name == null) return;
    track = state.track;
    while (track == null)
      Future.delayed(Duration(milliseconds: 500), () {
        getPlayerState().then((state) {
          track = state.track;
        });
      });
    playbackPosition = state.playbackPosition;
    isPaused = state.isPaused;
    playbackRestrictions = state.playbackRestrictions;
    isShuffling = state.playbackOptions.isShuffling;
    Future.delayed(Duration.zero, () async {
      isLiked = await ApiTrack.isTrackSaved(
          remoteAppProvider.spotifyApi, getTrackId());
    });
    initTimer();
    notifyListeners();
  }

  Future<PlayerState> fetchPlayerState() async {
    stopTimer();
    PlayerState playerState = await getPlayerState();
    track = playerState.track;
    playbackPosition = playerState.playbackPosition;
    isPaused = playerState.isPaused;
    playbackRestrictions = playerState.playbackRestrictions;
    isShuffling = playerState.playbackOptions.isShuffling;
    isLiked =
        await ApiTrack.isTrackSaved(remoteAppProvider.spotifyApi, getTrackId());
    initTimer();
    notifyListeners();
    return playerState;
  }

  void setContextTitle(String title) {
    contextTitle = title;
    notifyListeners();
  }

  void setContextSubtitle(String subtitle) {
    contextSubtitle = subtitle;
    notifyListeners();
  }

  void setTrack(Track t) {
    track = t;
    notifyListeners();
  }

  void setIsShuffling(bool shuffle) {
    setShuffle(shuffle: shuffle);
    isShuffling = shuffle;
    notifyListeners();
  }

  void setIsLiked(bool like) {
    isLiked = like;
    notifyListeners();
  }

  bool getIsLiked() => isLiked;

  void initTimer() {
    if (timer != null) timer.cancel();
    if (!isPaused)
      timer = Timer.periodic(new Duration(seconds: 1), (_) async {
        playbackPosition = playbackPosition + 1000;

        // Only session admin can go next song from his queue
        if (sessionId != null &&
            !isSessionAdmin &&
            playbackPosition >= track.duration - 3000) {
          makeAdminSender(sessionId);
          playbackPosition = track.duration - 4000; // reverse change
        }

        if (track != null && playbackPosition >= track.duration - 3000) {
          if (_queue.isNotEmpty)
            await this.queueNext();
          else
            await this.addHistory(track.uri);
          timer.cancel();
        }
        notifyListeners();
      });
  }

  void stopTimer() {
    if (timer != null) timer.cancel();
  }

  void setPosition(int position) {
    playbackPosition = position;
    notifyListeners();
  }

  int getPosition() {
    return playbackPosition;
  }

  void resume() {
    isPaused = false;
    notifyListeners();
  }

  void setIsPaused(bool paused) {
    isPaused = paused;
    if (isPaused) stopTimer();
    if (!isPaused) initTimer();
    notifyListeners();
  }

  void setRemoteAppProvider(SpotifyRemoteAppProvider provider) {
    remoteAppProvider = provider;
    // notifyListeners();
  }

  void setSessionId(String id) {
    sessionId = id;
    notifyListeners();
  }

  void setIsSessionAdmin(bool isAdmin) {
    isSessionAdmin = isAdmin;
    notifyListeners();
  }

  void setSenderUid(String sender) {
    senderUid = sender;
    notifyListeners();
  }

  void setIsSessionMaster(bool isMaster) {
    if (sessionId == null) return;
    isSessionMaster = isMaster;
    notifyListeners();
  }

  void setSessionMembers(List<String> members) {
    sessionMembers = members;
    notifyListeners();
  }

  void setEventId(String id) {
    eventId = id;
    notifyListeners();
  }

  void setIsEventAdmin(bool isAdmin) {
    isEventAdmin = isAdmin;
    notifyListeners();
  }

  void setEventTracks(List<EventTrack> tracks) async {
    eventTracks = tracks;
    notifyListeners();
  }

  void addEventTrack(EventTrack track) async {
    await sendPosition(this, playbackPosition);
    eventTracks.add(track);
    notifyListeners();
  }

  void setQueue(List<SpotifyDart.Track> newQueue) {
    _queue = newQueue ?? [];
    notifyListeners();
  }

  void addQueue(
      {SpotifyDart.Track track,
      List<SpotifyDart.Track> tracks,
      bool atFirst = false,
      bool clearQueue = false}) {
    if (clearQueue == true) {
      _queue = [];
    }
    if (tracks != null) {
      _queue = atFirst ? [...tracks, ..._queue] : [..._queue, ...tracks];
    } else if (track != null) {
      _queue = atFirst ? [track, ..._queue] : [..._queue, track];
    }
    if (_queue.length > 25) _queue.removeRange(25, _queue.length);
    notifyListeners();
  }

  Future<void> addHistory(String trackUri) async {
    if (eventId != null && isEventAdmin && _queue.length == 0)
      return resetSlider(this, eventId, true);

    ApiTrack.getTrack(remoteAppProvider.spotifyApi, null, trackUri: trackUri)
        .then((track) {
      _trackHistory.add(track);
      if (_trackHistory.length > 5)
        _trackHistory.removeRange(0, _trackHistory.length - 5);
      notifyListeners();
    });
  }

  Future<void> queuePrevious() async {
    if (_trackHistory.isEmpty) {
      Player.skipPrevious();
      return;
    }

    var currentTrackUri = track.uri;
    await playBySpotifyUri(
      buildContext,
      this,
      _trackHistory.last.uri,
      addHistory: false,
    );

    var currentTrack = await ApiTrack.getTrack(
        remoteAppProvider.spotifyApi, null,
        trackUri: currentTrackUri);
    addQueue(track: currentTrack, atFirst: true);
    _trackHistory.removeLast();
    notifyListeners();
  }

  Future<void> queueNext() async {
    if (eventId != null && !isEventAdmin) return;

    if (_queue.isEmpty) {
      await Player.skipNext();
      return;
    }

    await playBySpotifyUri(buildContext, this, _queue[0].uri, addHistory: true);
    _queue.removeAt(0);
    if (isEventAdmin) {
      EventsCollection().deleteTrack(eventId, eventTracks[0]);
      await resetSlider(this, eventId, false);
    }
  }

  void removeTrackQueueAt(int index) {
    _queue.removeAt(index);
    notifyListeners();
  }
}
