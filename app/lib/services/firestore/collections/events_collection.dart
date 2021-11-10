import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';

import '../../../app_localizations.dart';
import '../../../models/_models.dart';
import '../../../ui/utils/toast/toast_utils.dart';
import '../../../providers/spotify_player_provider.dart';
import '../../../services/realtime_database/databases/event_database.dart';
import '../../../utils/dart/listsExtension.dart';

import '../../../utils/logger.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class EventsCollection {
  EventsCollection();

  CollectionReference collection =
      FirebaseFirestore.instance.collection('events');

  Future<EventModel> createEvent(EventModel event) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:firestore:createEvent");
    EventModel evt;
    try {
      myTrace.start();

      event.keywords =
          event.name != null ? _generateKeywords(event.name) : List();
      DocumentReference doc = await collection.add(event.toJson());
      evt = await getEventById(doc.id);
      await EventDatabase().setData(evt);

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger().e("[EventsCollection.addEvent] Failed to add event: $err");
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
    return evt;
  }

  Future<EventModel> updateEvent(
      String eventId, Map<String, dynamic> data) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:firestore:updateEvent");
    EventModel evt;
    try {
      myTrace.start();

      data['keywords'] =
          data['name'] != null ? _generateKeywords(data['name']) : List();
      await collection.doc(eventId).update(data);
      evt = await getEventById(eventId);
      await EventDatabase().update(evt);

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger()
          .e("[EventsCollection.updateEvent] Failed to add event: $err");
      myTrace.incrementMetric("error", 1);
    }
    return evt;
  }

  Future<bool> deleteEvent(String eventId) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:firestore:deleteEvent");
    try {
      myTrace.start();

      await Future.wait([
        EventDatabase().delete(eventId),
        collection.doc(eventId).delete(),
      ]);

      myTrace.incrementMetric("success", 1);
      return true;
    } catch (err) {
      CustomLogger()
          .e("[EventsCollection.delete] Failed to delete event: $err");
      myTrace.incrementMetric("error", 1);
      return false;
    } finally {
      myTrace.stop();
    }
  }

  Future<EventModel> addTrack(
      BuildContext context, String eventId, Track track) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:firestore:addTrack");
    EventModel event;
    try {
      myTrace.start();

      SpotifyPlayerProvider playerProvider =
          Provider.of<SpotifyPlayerProvider>(context, listen: false);

      event = await getEventById(eventId);
      event.tracks = event?.tracks ?? [];
      if (event.tracks.indexWhere((t) => t.track.id == track.id) >= 0) {
        ToastUtils.showCustomToast(context,
            AppLocalizations.of(context).translate("itemAlreadyExists"),
            level: ToastLevel.Warn, durationSec: 5);
        return event;
      }
      EventTrack currentTrack = new EventTrack(track, newTrack: true);
      event.tracks.removeWhere((track) => track.track == null);
      event.tracks.add(currentTrack);
      await updateEvent(eventId, event.toJson());

      if (playerProvider.isEventAdmin) {
        playerProvider.addQueue(track: track);
        playerProvider.addEventTrack(currentTrack);
      }

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger()
          .e("[EventsCollection.updateEvent] Failed to add event: $err", err);
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
    return event;
  }

  Future<EventModel> deleteTrack(String eventId, EventTrack track) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:firestore:deleteTrack");
    EventModel event;
    try {
      myTrace.start();

      event = await getEventById(eventId);
      event.tracks.removeWhere((elem) {
        if (elem.track == null) {
          return false;
        }
        return elem.id == track.id && elem.track.id == track.track.id;
      });
      await updateEvent(eventId, event.toJson());

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger()
          .e("[EventsCollection.updateEvent] Failed to add event: $err");
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
    return event;
  }

  Future<List<String>> upvoteTrack(
      String eventId, String eventTrackId, String userId) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:firestore:upvoteTrack");
    try {
      myTrace.start();

      var event = await getEventById(eventId);
      var index = event.tracks.indexWhere((elem) => elem.id == eventTrackId);
      if (index >= 0) {
        var hasAlreadyVoted =
            event.tracks[index].upVotesUids.indexOf(userId) >= 0;
        if (hasAlreadyVoted) return event.tracks[index].upVotesUids;

        event.tracks[index].upVotesUids.add(userId);

        if (event.tracks.length > 1) {
          var sortedTracks = event.tracks.sublist(1);
          sortedTracks
            ..sort(
                (a, b) => b.upVotesUids.length.compareTo(a.upVotesUids.length));
          event.tracks = [event.tracks[0], ...sortedTracks];
        }
        await updateEvent(eventId, event.toJson());

        myTrace.incrementMetric("success", 1);
        return event.tracks[index].upVotesUids;
      }
    } catch (err) {
      CustomLogger()
          .e("[EventsCollection.upvoteTrack] Failed to upvote track: $err");
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
    return null;
  }

  Future<List<String>> downvoteTrack(
      String eventId, String eventTrackId, String userId) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:firestore:downvoteTrack");
    try {
      myTrace.start();

      var event = await getEventById(eventId);
      var index = event.tracks.indexWhere((elem) => elem.id == eventTrackId);
      if (index >= 0) {
        event.tracks[index].upVotesUids.removeWhere((id) => id == userId);

        if (event.tracks.length > 1) {
          var sortedTracks = event.tracks.sublist(1);
          sortedTracks
            ..sort(
                (a, b) => b.upVotesUids.length.compareTo(a.upVotesUids.length));
          event.tracks = [event.tracks[0], ...sortedTracks];
        }
        await updateEvent(eventId, event.toJson());

        myTrace.incrementMetric("success", 1);
        return event.tracks[index].upVotesUids;
      }
    } catch (err) {
      CustomLogger()
          .e("[EventsCollection.downvoteTrack] Failed to downvote track: $err");
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
    return null;
  }

  Future<bool> updateRights(
      String eventId, String userId, EventUsersRights rights) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:firestore:updateRights");
    try {
      myTrace.start();

      Map<String, dynamic> params = {};
      params["usersRights.$userId.read"] = rights.read;
      params["usersRights.$userId.edit"] = rights.edit;
      params["usersRights.$userId.vote"] = rights.vote;
      await EventDatabase().updateRights(eventId, userId, rights);
      await collection.doc(eventId).update(params);

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger()
          .e("[EventsCollection.getEventById] Failed to get event: $err");
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
    return true;
  }

  Future<bool> addFollower(String eventId, String userId) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:firestore:addFollower");
    try {
      myTrace.start();

      Map<String, dynamic> params = {};
      params["followers"] = FieldValue.arrayUnion([userId]);
      await EventDatabase().addFollower(eventId, userId);
      await collection.doc(eventId).update(params);

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger().e(
        "[EventsCollection.getEventById] Failed to get event: $err",
      );
      myTrace.incrementMetric("error", 1);
      return false;
    } finally {
      myTrace.stop();
    }
    return true;
  }

  Future<bool> removeFollower(String eventId, String userId) async {
    final Trace myTrace = FirebasePerformance.instance
        .newTrace("events:firestore:removeFollower");
    try {
      myTrace.start();

      Map<String, dynamic> params = {};
      params["followers"] = FieldValue.arrayRemove([userId]);
      await EventDatabase().removeFollower(eventId, userId);
      await collection.doc(eventId).update(params);

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger().e(
        "[EventsCollection.getEventById] Failed to get event: $err",
      );
      myTrace.incrementMetric("error", 1);
      return false;
    } finally {
      myTrace.stop();
    }
    return true;
  }

  Future<EventModel> getEventById(String eventId) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:firestore:getEventById");
    try {
      myTrace.start();

      var doc = await collection.doc(eventId).get();

      myTrace.incrementMetric("success", 1);
      return EventModel.fromJson(doc.data(), doc.id);
    } catch (err) {
      CustomLogger().e(
        "[EventsCollection.getEventById] Failed to get event: $err",
      );
      myTrace.incrementMetric("error", 1);
      return null;
    } finally {
      myTrace.stop();
    }
  }

  Future<List<EventModel>> findByAdminId(String adminUserId) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:firestore:findByAdminId");
    try {
      myTrace.start();

      var querySnapshot =
          await collection.where('adminUserId', isEqualTo: adminUserId).get();

      myTrace.incrementMetric("success", 1);
      return querySnapshot.docs
          .map((doc) => EventModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (err) {
      CustomLogger()
          .e("[EventsCollection.findByAdminId] Failed to get events: $err");
      myTrace.incrementMetric("error", 1);
      return [];
    } finally {
      myTrace.stop();
    }
  }

  Future<List<EventModel>> findByUserId(String userId,
      {bool writeOnly = false}) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("events:firestore:findByUserId");
    try {
      myTrace.start();

      var querySnapshot = await collection
          .where(
              writeOnly == true ? 'restrictedEdition' : 'restrictedVisibility',
              arrayContains: userId)
          .get();
      List<EventModel> eventsWithRights = [];
      querySnapshot.docs.forEach(
        (doc) => eventsWithRights.add(EventModel.fromJson(doc.data(), doc.id)),
      );
      eventsWithRights.removeWhere((e) => e.adminUserId == userId);

      myTrace.incrementMetric("success", 1);
      return eventsWithRights;
    } catch (err) {
      CustomLogger()
          .e("[EventsCollection.findByUserId] Failed to get events: $err");
      myTrace.incrementMetric("error", 1);
      return [];
    } finally {
      myTrace.stop();
    }
  }

  Future<List<EventModel>> findLikedByUserId(String userId,
      {bool writeOnly = false}) async {
    final Trace myTrace = FirebasePerformance.instance
        .newTrace("events:firestore:findLikedByUserId");
    try {
      myTrace.start();

      QuerySnapshot querySnapshot;
      if (writeOnly == true) {
        querySnapshot = await collection
            .where('usersRights.$userId.edit', isEqualTo: true)
            .where('followers', arrayContains: userId)
            .get();
      } else {
        querySnapshot =
            await collection.where('followers', arrayContains: userId).get();
      }

      myTrace.incrementMetric("success", 1);
      return querySnapshot.docs
          .map((doc) => EventModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (err) {
      CustomLogger().e(
          "[EventsCollection.findLikedByUserId] Failed to get liked events: $err");
      myTrace.incrementMetric("error", 1);
      return [];
    } finally {
      myTrace.stop();
    }
  }

  Future<ReadableEventsResults> searchReadableByUserId(
      String userId, String str,
      {ReadableEventsResults lastResults, num limit = 20}) async {
    final Trace myTrace = FirebasePerformance.instance
        .newTrace("events:firestore:searchReadableByUserId");
    try {
      myTrace.start();

      var pattern = str.trim().toLowerCase();

      var userCanReadQuery = collection
          .where('nameLower', isGreaterThanOrEqualTo: pattern)
          .where('nameLower', isLessThanOrEqualTo: pattern + '\uf8ff')
          .where('restrictedVisibility', arrayContains: userId)
          .orderBy('nameLower')
          // .orderBy('updatedAt')
          .limit(limit);
      var userCanReadPromise = lastResults?.userCanReadLastDoc != null
          ? userCanReadQuery
              .startAfterDocument(lastResults.userCanReadLastDoc)
              .get()
          : userCanReadQuery.get();

      var publicVisibilityQuery = collection
          .where('nameLower', isGreaterThanOrEqualTo: pattern)
          .where('nameLower', isLessThanOrEqualTo: pattern + '\uf8ff')
          .where('isPublic', isEqualTo: true)
          .orderBy('nameLower')
          // .orderBy('updatedAt')
          .limit(limit);
      var publicVisibilityPromise = lastResults?.publicVisibilityLastDoc != null
          ? publicVisibilityQuery
              .startAfterDocument(lastResults.publicVisibilityLastDoc)
              .get()
          : publicVisibilityQuery.get();

      var snaps = await Future.wait([
        userCanReadPromise,
        publicVisibilityPromise,
      ]);
      var docs = [...snaps[0].docs, ...snaps[1].docs];
      docs.unique((doc) => doc.id);

      myTrace.incrementMetric("success", 1);
      return ReadableEventsResults(
        docs:
            docs.map((doc) => EventModel.fromJson(doc.data(), doc.id)).toList(),
        userCanReadLastDoc:
            snaps[0].docs.length > 0 ? snaps[0].docs.last : null,
        publicVisibilityLastDoc:
            snaps[1].docs.length > 0 ? snaps[1].docs.last : null,
      );
    } catch (err) {
      CustomLogger().e(
          "[EventsCollabCollection.searchReadableByUserId] Failed to search readable collaboratives playlists: $err");
      myTrace.incrementMetric("error", 1);
      return ReadableEventsResults();
    } finally {
      myTrace.stop();
    }
  }

  Future<WritableEventsResults> searchWritableByUserId(
      String userId, String str,
      {WritableEventsResults lastResults, num limit = 20}) async {
    final Trace myTrace = FirebasePerformance.instance
        .newTrace("events:firestore:searchWritableByUserId");
    try {
      myTrace.start();

      var pattern = str.trim().toLowerCase();
      var userCanWriteQuery = collection
          .where('nameLower', isGreaterThanOrEqualTo: pattern)
          .where('nameLower', isLessThanOrEqualTo: pattern + '\uf8ff')
          .where('restrictedEdition', arrayContains: userId)
          .orderBy('nameLower')
          // .orderBy('updatedAt')
          .limit(limit);
      var userCanWritePromise = lastResults?.userCanEditLastDoc != null
          ? userCanWriteQuery
              .startAfterDocument(lastResults.userCanEditLastDoc)
              .get()
          : userCanWriteQuery.get();

      var querySnapshot = await userCanWritePromise;

      myTrace.incrementMetric("success", 1);
      return WritableEventsResults(
        docs: querySnapshot.docs
            .map((doc) => EventModel.fromJson(doc.data(), doc.id))
            .toList(),
        userCanEditLastDoc:
            querySnapshot.docs.length > 0 ? querySnapshot.docs.last : null,
      );
    } catch (err) {
      CustomLogger().e(
          "[EventsCollabCollection.searchWritableByUserId] Failed to search editable events: $err");
      myTrace.incrementMetric("error", 1);
      return WritableEventsResults();
    } finally {
      myTrace.stop();
    }
  }

  _createKeywords(String name) {
    List<String> arrName = List();
    String curName = '';
    name.split('').forEach((letter) {
      curName += letter;
      arrName.add(curName);
    });
    return arrName;
  }

  List<String> _generateKeywordList(List<String> words) {
    List<String> currentList = List();
    if (words == null) {
      return currentList;
    }
    if (words.length == 1) {
      return words;
    }
    List<String> start = [...words];
    List<String> end = [...words];
    start.removeLast();
    end.removeAt(0);
    currentList.add(start.join(' '));
    currentList.add(end.join(' '));
    currentList.addAll(_generateKeywordList(start));
    currentList.addAll(_generateKeywordList(end));
    return currentList;
  }

  _generateKeywords(String name) {
    String currentName = name.trim().toLowerCase();
    List<String> words = currentName.split(' ');
    List<String> keywordsList = _generateKeywordList(words);
    keywordsList.add(words.join(' '));
    keywordsList = keywordsList.toSet().toList();
    List<String> keywords = List();
    for (String keyword in keywordsList) {
      keywords.addAll(_createKeywords(keyword));
    }
    keywords = keywords.toSet().toList();
    return keywords;
  }
}

class ReadableEventsResults {
  final DocumentSnapshot userCanReadLastDoc;
  final DocumentSnapshot publicVisibilityLastDoc;
  List<EventModel> docs = [];

  ReadableEventsResults(
      {this.userCanReadLastDoc, this.publicVisibilityLastDoc, this.docs});
}

class WritableEventsResults {
  final DocumentSnapshot userCanEditLastDoc;
  List<EventModel> docs = [];

  WritableEventsResults({this.userCanEditLastDoc, this.docs});
}
