import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_performance/firebase_performance.dart';
// import 'package:logger/logger.dart';

import '.././../../models/_models.dart';

import '../../../utils/logger.dart';

class EventDatabase {
  final DatabaseReference database =
      FirebaseDatabase.instance.reference().child('events');

  EventDatabase();

  Future<DataSnapshot> getData(String eventId) async {
    return await database.child(eventId).once();
  }

  Future<void> setData(EventModel event) async {
    return await database.child(event.id).set(event.toJson());
  }

  Future<void> delete(String eventId) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:realtimedb:delete");
    try {
      myTrace.start();

      await database.child(eventId).set(null);

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger().e(err);
      myTrace.incrementMetric("error", 1);
      throw err;
    } finally {
      myTrace.stop();
    }
  }

  Future<void> update(EventModel event) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:realtimedb:update");
    try {
      myTrace.start();

      var snapshot = await database.child(event.id).once();
      var currEvt =
          EventModel.fromJson(jsonDecode(jsonEncode(snapshot.value)), event.id);
      var eventJson = event.toJson();

      // Don't update those datas (for realtime session management)
      eventJson['playbackPosition'] = currEvt.playbackPosition;
      eventJson['playbackPositionStartTime'] =
          currEvt.playbackPositionStartTime;
      eventJson['membersCounter'] = currEvt.membersCounter;
      eventJson['isPaused'] = currEvt.isPaused;

      await database.child(event.id).set(eventJson);

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger().e(err);
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
    return true;
  }

  Future<void> updateTracks(EventModel event) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:realtimedb:updateTracks");
    try {
      myTrace.start();

      var tracksJson = event.toJson()['tracks'];
      await database.child(event.id).child('tracks').set(tracksJson);

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger().e(err);
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
    return true;
  }

  Future<void> updateRights(
      String eventId, String userId, EventUsersRights rights) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:realtimedb:updateRights");
    try {
      myTrace.start();

      await database
          .child(eventId)
          .child('usersRights')
          .child(userId)
          .set(rights.toJson());

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger().e(err);
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
    return true;
  }

  Future<void> removeRights(String eventId, String userId) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:realtimedb:removeRights");
    try {
      myTrace.start();

      await database.child(eventId).child('usersRights').child(userId).set({});

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger().e(err);
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
    return true;
  }

  Future<void> removeData(EventModel event) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:realtimedb:removeData");
    try {
      myTrace.start();

      await database.child(event.id).remove();

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger().e(err);
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
  }

  DatabaseReference getQuery(String eventId) {
    return database.child(eventId);
  }

  DatabaseReference getFollowers(String eventId) {
    return database.child(eventId).child('followers');
  }

  DatabaseReference getUserRigths(String eventId, String userId) {
    return database.child(eventId).child('usersRights').child(userId);
  }

  DatabaseReference getUsersRigths(String eventId) {
    return database.child(eventId).child('usersRights');
  }

  Future<void> addFollower(String eventId, String userId) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:realtimedb:addFollower");
    try {
      myTrace.start();

      var eventRef = database.child(eventId).child('followers');
      await eventRef.runTransaction((currentArray) async {
        if (currentArray.value == null) {
          currentArray.value = [userId];
        } else {
          List<dynamic> newList = [...currentArray.value, userId];
          currentArray.value = newList;
        }
        return currentArray;
      });

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger().e(err);
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
  }

  Future<void> removeFollower(String eventId, String userId) async {
    final Trace myTrace = FirebasePerformance.instance
        .newTrace("events:realtimedb:removeFollower");
    try {
      myTrace.start();

      var eventRef = database.child(eventId).child('followers');
      await eventRef.runTransaction((currentArray) async {
        List<dynamic> newList = [
          ...(currentArray.value as List<dynamic> ?? [])
        ];
        newList.removeWhere((v) => v == userId);
        currentArray.value = newList;
        return currentArray;
      });

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger().e(err);
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
  }
}
