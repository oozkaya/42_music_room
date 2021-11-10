import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';

import '../../../models/_models.dart';
import '../../../services/spotify/player_state.dart';
import '../../../services/spotify/player_basics.dart';
import '../../../providers/spotify_player_provider.dart';
import './sessions.dart';

import '../../../utils/logger.dart';

final databaseReference = FirebaseDatabase.instance.reference();

Stream<Event> onEventChanged(String eventId) {
  var eventRef = databaseReference.child('events').child(eventId);
  return eventRef.onValue;
}

Future<void> sendTracks(
    String eventId, List<EventTrack> tracks, bool isEventAdmin) async {
  if (eventId == null || !isEventAdmin) return;
  try {
    var tracksRef =
        databaseReference.child('events').child(eventId).child('tracks');

    var jsonTracks = tracks?.map((e) => e?.toJson())?.toList();
    await tracksRef.set(jsonTracks);
  } catch (err) {
    CustomLogger().e(err);
  }
}

Future<void> sendIsPaused(
    String eventId, bool isPaused, bool isEventAdmin) async {
  if (eventId == null || !isEventAdmin) return;
  try {
    var isPausedRef =
        databaseReference.child('events').child(eventId).child('isPaused');

    await isPausedRef.set(isPaused);
  } catch (err) {
    CustomLogger().e(err);
  }
}

Future<void> resetSlider(
  SpotifyPlayerProvider playerProvider,
  String eventId,
  bool shouldSeekTo,
) async {
  await sendPosition(eventId, 0, playerProvider.isEventAdmin);
  await sendIsPaused(eventId, true, playerProvider.isEventAdmin);
  await sendIsPaused(eventId, false, playerProvider.isEventAdmin);
  playerProvider.setPosition(0);
  if (shouldSeekTo) await seekTo(0);
  Future.delayed(Duration.zero, () async {
    playerProvider.initTimer();
  });
}

Future<void> sendPosition(
    String eventId, int position, bool isEventAdmin) async {
  if (eventId == null || !isEventAdmin) return;
  try {
    var positionRef = databaseReference
        .child('events')
        .child(eventId)
        .child('playbackPosition');
    var positionTimeRef = databaseReference
        .child('events')
        .child(eventId)
        .child('playbackPositionStartTime');

    await positionRef.set(position);
    await positionTimeRef.set(DateTime.now().millisecondsSinceEpoch);
  } catch (err) {
    CustomLogger().e(err);
  }
}

Future<void> joinEvent(SpotifyPlayerProvider playerProvider, String eventId,
    BuildContext context) async {
  try {
    String userUid = FirebaseAuth.instance.currentUser.uid;
    var userEventRef =
        databaseReference.child('users').child(userUid).child('event');
    var eventMembersCounterRef = databaseReference
        .child('events')
        .child(eventId)
        .child('membersCounter');

    var snapshot = await eventMembersCounterRef.once();
    var membersCounter = snapshot.value;
    await eventMembersCounterRef.set(membersCounter + 1);

    await userEventRef.set(eventId);
    playerProvider.setEventId(eventId);
    Navigator.of(context).pop();
  } catch (err) {
    CustomLogger().e(err);
  }
}

Future<void> kickFromEvent(
    SpotifyPlayerProvider playerProvider, String eventId) async {
  try {
    String userUid = FirebaseAuth.instance.currentUser.uid;
    bool isEventAdmin = playerProvider.isEventAdmin;
    var userEventRef =
        databaseReference.child('users').child(userUid).child('event');
    var eventMembersCounterRef = databaseReference
        .child('events')
        .child(eventId)
        .child('membersCounter');

    var snapshot = await eventMembersCounterRef.once();
    var membersCounter = snapshot.value;
    if (membersCounter != null)
      await eventMembersCounterRef.set(membersCounter - 1);

    if (isEventAdmin) {
      await sendIsPaused(eventId, true, isEventAdmin);
      await sendPosition(eventId, 0, isEventAdmin);
    }
    await userEventRef.remove();
    await pause();
  } catch (err) {
    CustomLogger().e(err);
  }
}

Future<void> cleanEvent(
    SpotifyPlayerProvider playerProvider, String eventId) async {
  try {
    String userUid = FirebaseAuth.instance.currentUser.uid;
    var userEventRef =
        databaseReference.child('users').child(userUid).child('event');

    // await EventsCollection().deleteEvent(eventId);
    await userEventRef.remove();
    playerProvider.setEventId(null);
  } catch (err) {
    CustomLogger().e(err);
  }
}
