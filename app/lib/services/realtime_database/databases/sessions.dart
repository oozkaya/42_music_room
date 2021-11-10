import 'dart:async';

import 'package:MusicRoom42/services/spotify/player_basics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_performance/firebase_performance.dart';
// import 'package:logger/logger.dart';

import '../../../models/_models.dart';
import '../../../providers/spotify_player_provider.dart';

import '../../../utils/logger.dart';

final databaseReference = FirebaseDatabase.instance.reference();

Future<void> createSession(SpotifyPlayerProvider playerProvider) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("sessions:createSession");
  try {
    myTrace.start();

    String userUid = FirebaseAuth.instance.currentUser.uid;
    var userSessionRef =
        databaseReference.child('users').child(userUid).child('session');
    var sessionRef = databaseReference.child('sessions').child(userUid);
    await pause();
    playerProvider.setIsPaused(true);
    SessionModel session = SessionModel(
      adminUid: userUid,
      masterUid: userUid,
      trackUri: playerProvider.track?.uri,
      playbackPosition: playerProvider.playbackPosition,
      playbackPositionStartTime: 0,
      isPaused: true,
      members: [userUid],
      senderUid: userUid,
    );
    await userSessionRef.set(userUid);
    await sessionRef.set(session.toJson());
    playerProvider.setSessionId(userUid);
    playerProvider.setSenderUid(userUid);
    playerProvider.setIsSessionMaster(true);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
  } finally {
    myTrace.stop();
  }
}

Stream<Event> onSessionChanged(String sessionId) {
  var sessionRef = databaseReference.child('sessions').child(sessionId);
  return sessionRef.onValue;
}

Future<void> sendMasterUid(String sessionId, String masterUid) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("sessions:sendMasterUid");
  if (sessionId == null) return;
  String userUid = FirebaseAuth.instance.currentUser.uid;
  try {
    myTrace.start();

    var masterRef =
        databaseReference.child('sessions').child(sessionId).child('masterUid');
    var senderUidRef =
        databaseReference.child('sessions').child(sessionId).child('senderUid');

    await masterRef.set(masterUid);
    await senderUidRef.set(userUid);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
  } finally {
    myTrace.stop();
  }
}

Future<void> sendTrackUri(String sessionId, String trackUri) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("sessions:sendTrackUri");
  String userUid = FirebaseAuth.instance.currentUser.uid;
  try {
    myTrace.start();

    var trackUriRef =
        databaseReference.child('sessions').child(sessionId).child('trackUri');
    var senderUidRef =
        databaseReference.child('sessions').child(sessionId).child('senderUid');

    await trackUriRef.set(trackUri);
    await senderUidRef.set(userUid);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
  } finally {
    myTrace.stop();
  }
}

Future<void> sendIsPaused(String sessionId, bool isPaused) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("sessions:sendIsPaused");
  if (sessionId == null) return;
  String userUid = FirebaseAuth.instance.currentUser.uid;
  try {
    myTrace.start();

    var isPausedRef =
        databaseReference.child('sessions').child(sessionId).child('isPaused');
    var senderUidRef =
        databaseReference.child('sessions').child(sessionId).child('senderUid');

    await isPausedRef.set(isPaused);
    await senderUidRef.set(userUid);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
  } finally {
    myTrace.stop();
  }
}

Future<void> sendPosition(String sessionId, int position) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("sessions:sendPosition");
  if (sessionId == null) return;
  String userUid = FirebaseAuth.instance.currentUser.uid;
  try {
    myTrace.start();

    var positionRef = databaseReference
        .child('sessions')
        .child(sessionId)
        .child('playbackPosition');
    var positionTimeRef = databaseReference
        .child('sessions')
        .child(sessionId)
        .child('playbackPositionStartTime');
    var senderUidRef =
        databaseReference.child('sessions').child(sessionId).child('senderUid');

    await positionRef.set(position);
    await positionTimeRef.set(DateTime.now().millisecondsSinceEpoch);
    await senderUidRef.set(userUid);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
  } finally {
    myTrace.stop();
  }
}

Future<void> makeAdminSender(String sessionId) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("sessions:makeAdminSender");
  if (sessionId == null) return;
  try {
    myTrace.start();

    var senderUidRef =
        databaseReference.child('sessions').child(sessionId).child('senderUid');

    // sessionId is always equal to adminId
    await senderUidRef.set(sessionId);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
  } finally {
    myTrace.stop();
  }
}

Future<void> addToSession(String userUid, String sessionId) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("sessions:addToSession");
  try {
    myTrace.start();

    var userSessionRef =
        databaseReference.child('users').child(userUid).child('session');
    var sessionRef = databaseReference.child('sessions').child(sessionId);

    var sessionSnap = await sessionRef.once();
    var session = SessionModel.fromJson(sessionSnap.value);
    session.members.add(userUid);

    await Future.wait([
      userSessionRef.set(sessionId),
      sessionRef.set(session.toJson()),
    ]);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
  } finally {
    myTrace.stop();
  }
}

Future<void> kickFromSession(String userUid, String sessionId) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("sessions:kickFromSession");
  try {
    myTrace.start();

    var userSessionRef =
        databaseReference.child('users').child(userUid).child('session');
    var sessionRef = databaseReference.child('sessions').child(sessionId);

    var sessionSnap = await sessionRef.once();
    var session = SessionModel.fromJson(sessionSnap.value);
    session.members.removeWhere((memberUid) => memberUid == userUid);

    await Future.wait([
      userSessionRef.remove(),
      sessionRef.set(session.toJson()),
    ]);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
  } finally {
    myTrace.stop();
  }
}

Future<void> cleanSession(String sessionId) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("sessions:cleanSession");
  try {
    myTrace.start();

    var sessionRef = databaseReference.child('sessions').child(sessionId);
    var sessionMembersRef =
        databaseReference.child('sessions').child(sessionId).child('members');

    var snapshot = await sessionMembersRef.once();
    var members = new List<String>.from(snapshot.value);
    for (var memberUid in members) {
      var memberSessionRef =
          databaseReference.child('users').child(memberUid).child('session');
      await memberSessionRef.remove();
    }

    await sessionRef.remove();

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
  } finally {
    myTrace.stop();
  }
}

Future<void> takeSessionLead(
  SpotifyPlayerProvider playerProvider,
) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("sessions:takeSessionLead");
  var sessionId = playerProvider.sessionId;
  if (sessionId == null) return;

  try {
    myTrace.start();

    var userUid = FirebaseAuth.instance.currentUser.uid;
    await sendMasterUid(sessionId, userUid);
    playerProvider.setIsSessionMaster(true);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
  } finally {
    myTrace.stop();
  }
}
