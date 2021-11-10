import 'dart:async';

import 'package:MusicRoom42/services/firestore/collections/events_collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../../../../models/_models.dart';

class EventLike extends StatefulWidget {
  final EventModel event;

  EventLike(this.event);

  @override
  _EventLikeState createState() => _EventLikeState();
}

class _EventLikeState extends State<EventLike> {
  bool isAdmin = false;
  bool isLiked = false;
  bool isLoading = false;
  var currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    isAdmin = widget.event.adminUserId == currentUser.uid;
    isLiked = widget.event.followers.indexOf(currentUser.uid) != -1;
    super.initState();
  }

  onLikePressed() async {
    bool isUpdated;
    setState(() => isLoading = true);
    if (isLiked == false) {
      isUpdated = await EventsCollection()
          .addFollower(widget.event.id, currentUser.uid);
    } else {
      isUpdated = await EventsCollection()
          .removeFollower(widget.event.id, currentUser.uid);
    }
    if (isUpdated) {
      setState(() {
        isLoading = false;
        isLiked = !isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var shouldDisplayLikeButton = isAdmin == false;

    return shouldDisplayLikeButton
        ? IconButton(
            icon: isLoading == true
                ? CircularProgressIndicator()
                : isLiked == true
                    ? Icon(
                        LineIcons.heartAlt,
                        color: Colors.green,
                      )
                    : Icon(
                        LineIcons.heart,
                        color: Colors.grey.shade400,
                      ),
            onPressed: () {
              runZonedGuarded(() {
                onLikePressed();
              }, (error, stackTrace) {
                FirebaseCrashlytics.instance.recordError(error, stackTrace);
              });
            },
          )
        : Container();
  }
}
