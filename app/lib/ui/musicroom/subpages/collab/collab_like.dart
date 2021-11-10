import 'dart:async';

import 'package:MusicRoom42/services/firestore/collections/collabs_collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../../../../models/_models.dart';

class CollabLike extends StatefulWidget {
  final Collab collab;
  final bool isAdmin;
  final CollabUserRights userRights;

  CollabLike(
    this.collab, {
    this.isAdmin,
    this.userRights,
  });

  @override
  _CollabLikeState createState() => _CollabLikeState();
}

class _CollabLikeState extends State<CollabLike> {
  bool isLiked = false;
  var currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    isLiked = widget.collab.likes.indexOf(currentUser.uid) != -1;
    super.initState();
  }

  onLikePressed() async {
    Collab updatedCollab;
    if (isLiked == false) {
      updatedCollab = await CollabsCollection()
          .likeCollab(widget.collab.id, currentUser.uid);
    } else {
      updatedCollab = await CollabsCollection()
          .unlikeCollab(widget.collab.id, currentUser.uid);
    }
    if (updatedCollab != null) {
      setState(() => isLiked = !isLiked);
    }
  }

  @override
  Widget build(BuildContext context) {
    var shouldDisplayLikeButton = widget.isAdmin == false;

    return shouldDisplayLikeButton == false
        ? Container()
        : IconButton(
            icon: isLiked == true
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
          );
  }
}
