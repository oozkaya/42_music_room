import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_performance/firebase_performance.dart';
// import 'package:logger/logger.dart';

import 'package:MusicRoom42/models/_models.dart';

import '../../../utils/logger.dart';

final databaseReference = FirebaseDatabase.instance.reference();

Future<bool> validateUniqueNickname(UserModel user) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("users:validateUniqueNickname");
  bool res = false;
  try {
    myTrace.start();

    var nicknameRef = databaseReference
        .child('users')
        .orderByChild('nickName')
        .equalTo(user.nickName);
    DataSnapshot snapshot = await nicknameRef.once();
    var uidFound = snapshot.value?.keys?.first;
    if (snapshot.value == null || uidFound == null) {
      res = true;
    }

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
  } finally {
    myTrace.stop();
  }
  return res;
}

Future<dynamic> upsertUser(UserModel user) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("users:upsertUser");
  try {
    myTrace.start();

    var isNicknameUnique = await validateUniqueNickname(user);
    if (isNicknameUnique == false) {
      return 'nickName exists';
    }
    var userRef = databaseReference.child('users').child(user.uid);
    var json = user.toJson();
    await userRef.set(json);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
  } finally {
    myTrace.stop();
  }
}

Future<UserModel> getUser(String uid) async {
  final Trace myTrace = FirebasePerformance.instance.newTrace("users:getUser");
  UserModel user;
  try {
    myTrace.start();

    var userRef = databaseReference.child('users').child(uid);
    DataSnapshot snapshot = await userRef.once();
    if (snapshot.value == null) return null;
    user = UserModel.fromJson(snapshot.value, uid);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
    return null;
  } finally {
    myTrace.stop();
  }
  return user;
}

Future<List<UserModel>> getUsers() async {
  final Trace myTrace = FirebasePerformance.instance.newTrace("users:getUsers");
  List<UserModel> users = [];
  try {
    myTrace.start();

    var userRef = databaseReference.child('users');
    DataSnapshot snapshot = await userRef.once();
    snapshot.value.forEach((uid, user) {
      UserModel u = UserModel.fromJson(user, uid);
      users.add(u);
    });

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
    return null;
  } finally {
    myTrace.stop();
  }
  return users;
}

Future<List<UserModel>> getUsersFromUids(List<String> uids) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("users:getUsersFromUids");
  List<UserModel> users = [];

  if (uids == null || uids.length == 0) return users;
  try {
    myTrace.start();

    var res = await Future.wait(uids.map(getUser));
    res.forEach((element) {
      if (element != null) users.add(element);
    });

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
    return users;
  } finally {
    myTrace.stop();
  }
  return users;
}

Future<List<UserModel>> getSpecificUsers(List<String> userUids) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("users:getSpecificUsers");
  List<UserModel> users = [];
  try {
    myTrace.start();

    for (String userUid in userUids) {
      var userRef = databaseReference.child('users').child(userUid);
      DataSnapshot snapshot = await userRef.once();
      UserModel user = UserModel.fromJson(snapshot.value, userUid);
      users.add(user);
    }

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
    return null;
  } finally {
    myTrace.stop();
  }
  return users;
}

Future<dynamic> searchUsers(String start) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("users:searchUsers");
  List<UserModel> users = [];
  try {
    myTrace.start();

    var usersRef = databaseReference
        .child('users')
        .orderByChild('nickName')
        .startAt(start)
        .endAt(start + "\uf8ff");
    DataSnapshot snapshot = await usersRef.once();
    if (snapshot.value == null) return 'none';
    snapshot.value.forEach((uid, user) {
      UserModel u = UserModel.fromJson(user, uid);
      users.add(u);
    });

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
    return null;
  } finally {
    myTrace.stop();
  }
  return users;
}

Future<bool> addFriend(String friendUid) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("users:addFriend");
  try {
    myTrace.start();

    UserModel friend = await getUser(friendUid);
    if (friend != null) {
      String userUid = FirebaseAuth.instance.currentUser.uid;
      var friendRef = databaseReference
          .child('users')
          .child(friendUid)
          .child('friends')
          .child(userUid);
      var userRef = databaseReference
          .child('users')
          .child(userUid)
          .child('friends')
          .child(friendUid);
      await friendRef.set(userUid);
      await userRef.set(friendUid);

      myTrace.incrementMetric("success", 1);
    } else {
      return false;
    }
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
  } finally {
    myTrace.stop();
  }
  return true;
}

Future<void> deleteFriend(String friendUid) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("users:deleteFriend");
  try {
    myTrace.start();

    String userUid = FirebaseAuth.instance.currentUser.uid;
    var friendRef = databaseReference
        .child('users')
        .child(friendUid)
        .child('friends')
        .child(userUid);
    var userRef = databaseReference
        .child('users')
        .child(userUid)
        .child('friends')
        .child(friendUid);
    await friendRef.remove();
    await userRef.remove();

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
  } finally {
    myTrace.stop();
  }
}

Future<dynamic> getFriends(String uid) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("users:getFriends");
  List<UserModel> users = [];
  try {
    myTrace.start();

    var friendsRef =
        databaseReference.child('users').child(uid).child('friends');
    DataSnapshot snapshot = await friendsRef.once();
    if (snapshot.value == null) return 'none';
    for (String key in snapshot.value.keys) {
      UserModel u = await getUser(key);
      users.add(u);
    }

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
    return null;
  } finally {
    myTrace.stop();
  }
  return users;
}

DatabaseReference getUserEvents() {
  String userUid = FirebaseAuth.instance.currentUser.uid;
  return databaseReference.child('users').child(userUid).child('events');
}

Stream<Event> onUserSessionChanged() {
  String userUid = FirebaseAuth.instance.currentUser.uid;
  var userSessionRef =
      databaseReference.child('users').child(userUid).child('session');
  return userSessionRef.onValue;
}

Stream<Event> onUserEventChanged() {
  String userUid = FirebaseAuth.instance.currentUser.uid;
  var userSessionRef =
      databaseReference.child('users').child(userUid).child('event');
  return userSessionRef.onValue;
}
