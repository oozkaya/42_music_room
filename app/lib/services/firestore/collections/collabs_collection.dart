import 'dart:async';

import 'package:MusicRoom42/ui/utils/toast/toast_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
import 'package:spotify/spotify.dart';

import '../../../app_localizations.dart';
import '../../../models/_models.dart';
import '../../../utils/dart/listsExtension.dart';

import '../../../utils/logger.dart';

String documentIdFromCurrentDate() => DateTime.now().toIso8601String();

class CollabsCollection {
  CollabsCollection();

  CollectionReference collection =
      FirebaseFirestore.instance.collection('playlists_collaboratives');

  Future<String> create(Collab playlistCollaborative) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("collabs:create");
    try {
      myTrace.start();

      var now = DateTime.now();
      playlistCollaborative.createdAt = now;
      playlistCollaborative.updatedAt = now;
      var docRef = await collection.add(playlistCollaborative.toJson());

      myTrace.incrementMetric("success", 1);
      return docRef.id;
    } catch (err) {
      CustomLogger().e(
          "[CollabsCollection.create] Failed to add collaborative playlist: $err");
      myTrace.incrementMetric("error", 1);
      return null;
    } finally {
      myTrace.stop();
    }
  }

  Future<Collab> findOneById(String playlistCollaborativeId) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("collabs:findOneById");
    try {
      myTrace.start();

      var doc = await collection.doc(playlistCollaborativeId).get();

      myTrace.incrementMetric("success", 1);
      return Collab.fromJson(doc.data(), doc.id);
    } catch (err) {
      CustomLogger().e(
          "[CollabsCollection.findOneById] Failed to get collaborative playlist: $err");
      myTrace.incrementMetric("error", 1);
      return null;
    } finally {
      myTrace.stop();
    }
  }

  Future<List<Collab>> findByAdminId(String adminUserId) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("collabs:findByAdminId");
    try {
      myTrace.start();

      var querySnapshot =
          await collection.where('adminUserId', isEqualTo: adminUserId).get();

      myTrace.incrementMetric("success", 1);
      return querySnapshot.docs
          .map((doc) => Collab.fromJson(doc.data(), doc.id))
          .toList();
    } catch (err) {
      CustomLogger().e(
          "[CollabsCollection.findByAdminId] Failed to get collaboratives playlists: $err");
      myTrace.incrementMetric("error", 1);
      return [];
    } finally {
      myTrace.stop();
    }
  }

  Future<List<Collab>> findByUserId(String userId,
      {bool writeOnly = false}) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("collabs:findByUserId");
    try {
      myTrace.start();

      var querySnapshot = await collection
          .where(
              writeOnly == true
                  ? 'rights.restrictedEdition'
                  : 'rights.restrictedVisibility',
              arrayContains: userId)
          .get();
      List<Collab> collabsWithRights = [];
      querySnapshot.docs.forEach(
        (doc) => collabsWithRights.add(Collab.fromJson(doc.data(), doc.id)),
      );
      collabsWithRights.removeWhere((e) => e.adminUserId == userId);

      myTrace.incrementMetric("success", 1);
      return collabsWithRights;
    } catch (err) {
      CustomLogger().e(
          "[CollabsCollection.findByUserId] Failed to get collaboratives playlists: $err");
      myTrace.incrementMetric("error", 1);
      return [];
    } finally {
      myTrace.stop();
    }
  }

  Future<List<Collab>> findLikedByUserId(String userId,
      {bool writeOnly = false}) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("collabs:findLikedByUserId");
    try {
      myTrace.start();

      QuerySnapshot querySnapshot;
      if (writeOnly == true) {
        querySnapshot = await collection
            .where('rights.isEditionPublic', isEqualTo: true)
            .where('likes', arrayContains: userId)
            .get();
      } else {
        querySnapshot =
            await collection.where('likes', arrayContains: userId).get();
      }

      myTrace.incrementMetric("success", 1);
      return querySnapshot.docs
          .map((doc) => Collab.fromJson(doc.data(), doc.id))
          .toList();
    } catch (err) {
      CustomLogger().e(
          "[CollabsCollection.findLikedByUserId] Failed to get liked collaboratives playlists: $err");
      myTrace.incrementMetric("error", 1);
      return [];
    } finally {
      myTrace.stop();
    }
  }

  Future<List<Collab>> findAll() async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("collabs:findAll");
    try {
      myTrace.start();

      var querySnapshot = await collection.get();

      myTrace.incrementMetric("success", 1);
      return querySnapshot.docs
          .map((doc) => Collab.fromJson(doc.data(), doc.id))
          .toList();
    } catch (err) {
      CustomLogger().e(
          "[CollabsCollection.findAll] Failed to get collaboratives playlists: $err");
      myTrace.incrementMetric("error", 1);
      return [];
    } finally {
      myTrace.stop();
    }
  }

  Future<ReadableCollabsResults> searchReadableByUserId(
      String userId, String str,
      {ReadableCollabsResults lastResults, num limit = 20}) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("collabs:searchReadableByUserId");
    try {
      myTrace.start();

      var pattern = str.toLowerCase();

      var userCanReadQuery = collection
          .where('nameLower', isGreaterThanOrEqualTo: pattern)
          .where('nameLower', isLessThanOrEqualTo: pattern + '\uf8ff')
          .where('rights.restrictedVisibility', arrayContains: userId)
          .orderBy('nameLower')
          .orderBy('updatedAt')
          .limit(limit);
      var userCanReadPromise = lastResults?.userCanReadLastDoc != null
          ? userCanReadQuery
              .startAfterDocument(lastResults.userCanReadLastDoc)
              .get()
          : userCanReadQuery.get();

      var publicVisibilityQuery = collection
          .where('nameLower', isGreaterThanOrEqualTo: pattern)
          .where('nameLower', isLessThanOrEqualTo: pattern + '\uf8ff')
          .where('rights.isVisibilityPublic', isEqualTo: true)
          .orderBy('nameLower')
          .orderBy('updatedAt')
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
      return ReadableCollabsResults(
        docs: docs.map((doc) => Collab.fromJson(doc.data(), doc.id)).toList(),
        userCanReadLastDoc:
            snaps[0].docs.length > 0 ? snaps[0].docs.last : null,
        publicVisibilityLastDoc:
            snaps[1].docs.length > 0 ? snaps[1].docs.last : null,
      );
    } catch (err) {
      CustomLogger().e(
          "[CollabsCollection.searchReadableByUserId] Failed to search readable collaboratives playlists: $err");
      myTrace.incrementMetric("error", 1);
      return ReadableCollabsResults();
    } finally {
      myTrace.stop();
    }
  }

  Future<WritableCollabsResults> searchWritableByUserId(
      String userId, String str,
      {WritableCollabsResults lastResults, num limit = 20}) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("collabs:searchWritableByUserId");
    try {
      myTrace.start();

      var pattern = str.toLowerCase();
      var userCanWriteQuery = collection
          .where('nameLower', isGreaterThanOrEqualTo: pattern)
          .where('nameLower', isLessThanOrEqualTo: pattern + '\uf8ff')
          .where('rights.restrictedEdition', arrayContains: userId)
          .orderBy('nameLower')
          .orderBy('updatedAt')
          .limit(limit);
      var userCanWritePromise = lastResults?.userCanWriteLastDoc != null
          ? userCanWriteQuery
              .startAfterDocument(lastResults.userCanWriteLastDoc)
              .get()
          : userCanWriteQuery.get();

      var publicEditionQuery = collection
          .where('nameLower', isGreaterThanOrEqualTo: pattern)
          .where('nameLower', isLessThanOrEqualTo: pattern + '\uf8ff')
          .where('rights.isEditionPublic', isEqualTo: true)
          .orderBy('nameLower')
          .orderBy('updatedAt')
          .limit(limit);
      var publicEditionPromise = lastResults?.publicEditionLastDoc != null
          ? publicEditionQuery
              .startAfterDocument(lastResults.publicEditionLastDoc)
              .get()
          : publicEditionQuery.get();

      var snaps =
          await Future.wait([userCanWritePromise, publicEditionPromise]);
      var docs = [...snaps[0].docs, ...snaps[1].docs];
      docs.unique((doc) => doc.id);

      myTrace.incrementMetric("success", 1);
      return WritableCollabsResults(
        docs: docs.map((doc) => Collab.fromJson(doc.data(), doc.id)).toList(),
        userCanWriteLastDoc:
            snaps[0].docs.length > 0 ? snaps[0].docs.last : null,
        publicEditionLastDoc:
            snaps[1].docs.length > 0 ? snaps[1].docs.last : null,
      );
    } catch (err) {
      CustomLogger().e(
          "[CollabsCollection.searchWritableByUserId] Failed to search writable collaboratives playlists: $err");
      myTrace.incrementMetric("error", 1);
      return WritableCollabsResults();
    } finally {
      myTrace.stop();
    }
  }

  Future<bool> delete(String playlistCollaborativeId) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("collabs:delete");
    try {
      myTrace.start();

      await collection.doc(playlistCollaborativeId).delete();

      myTrace.incrementMetric("success", 1);
      return true;
    } catch (err) {
      CustomLogger().e(
          "[CollabsCollection.delete] Failed to delete collaborative playlist: $err");
      myTrace.incrementMetric("error", 1);
      return false;
    } finally {
      myTrace.stop();
    }
  }

  Future<void> update(String playlistCollaborativeId, Collab collab) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("collabs:update");
    try {
      myTrace.start();

      collab.updatedAt = DateTime.now();
      await collection.doc(playlistCollaborativeId).update(collab.toJson());

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger().e(
          "[CollabsCollection.update] Failed to update collaborative playlist: $err");
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
  }

  Stream<DocumentSnapshot> documentStream<T>(String collabId) {
    final DocumentReference reference = collection.doc(collabId);
    return reference.snapshots();
  }

  Future<Collab> addTrack(
      BuildContext context, String collabId, Track track) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("collabs:addTrack");
    Collab collab;
    try {
      myTrace.start();

      collab = await findOneById(collabId);
      if (collab.tracks.indexWhere((t) => t.id == track.id) >= 0) {
        ToastUtils.showCustomToast(context,
            AppLocalizations.of(context).translate("itemAlreadyExists"),
            level: ToastLevel.Warn, durationSec: 5);
        return collab;
      }
      collab.tracks.add(track);
      await update(collabId, collab);

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger()
          .e("[CollabsCollection.addTrack] Failed to add track: $err");
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
    return collab;
  }

  Future<Collab> remoteTrack(
      String collabId, int trackIndex, String trackId) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("collabs:remoteTrack");
    Collab collab;
    try {
      myTrace.start();

      collab = await findOneById(collabId);
      if (collab.tracks.elementAt(trackIndex)?.id == trackId) {
        collab.tracks.removeAt(trackIndex);
      } else {
        collab.tracks.removeWhere((t) => t.id == trackId);
      }
      await update(collabId, collab);

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger()
          .e("[CollabsCollection.remoteTrack] Failed to remove track: $err");
      myTrace.incrementMetric("error", 1);
    } finally {
      myTrace.stop();
    }
    return collab;
  }

  Future<Collab> likeCollab(String collabId, String userId) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("collabs:likeCollab");
    Collab collab;
    try {
      myTrace.start();

      collab = await findOneById(collabId);
      var isAlreadyLiked = collab.likes.indexOf(userId) != -1;
      if (isAlreadyLiked) return collab;
      collab.likes.add(userId);
      await update(collabId, collab);

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger()
          .e("[CollabsCollection.likeCollab] Failed to like collab: $err");
      myTrace.incrementMetric("error", 1);
      return null;
    } finally {
      myTrace.stop();
    }
    return collab;
  }

  Future<Collab> unlikeCollab(String collabId, String userId) async {
    final Trace myTrace =
        FirebasePerformance.instance.newTrace("collabs:unlikeCollab");
    Collab collab;
    try {
      collab = await findOneById(collabId);
      collab.likes.removeWhere((uid) => uid == userId);
      await update(collabId, collab);

      myTrace.incrementMetric("success", 1);
    } catch (err) {
      CustomLogger()
          .e("[CollabsCollection.unlikeCollab] Failed to unlike collab: $err");
      myTrace.incrementMetric("error", 1);
      return null;
    } finally {
      myTrace.stop();
    }
    return collab;
  }
}

class ReadableCollabsResults {
  final DocumentSnapshot userCanReadLastDoc;
  final DocumentSnapshot publicVisibilityLastDoc;
  List<Collab> docs = [];

  ReadableCollabsResults(
      {this.userCanReadLastDoc, this.publicVisibilityLastDoc, this.docs});
}

class WritableCollabsResults {
  final DocumentSnapshot userCanWriteLastDoc;
  final DocumentSnapshot publicEditionLastDoc;
  List<Collab> docs = [];

  WritableCollabsResults(
      {this.userCanWriteLastDoc, this.publicEditionLastDoc, this.docs});
}
