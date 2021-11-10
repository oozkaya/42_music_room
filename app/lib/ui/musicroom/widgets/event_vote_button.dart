import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import '../../../models/_models.dart';
import '../../../services/firestore/collections/events_collection.dart';

class EventVoteButton extends StatefulWidget {
  final EventModel event;
  final EventTrack eventTrack;
  final double distanceKmFromEvent;

  const EventVoteButton(this.event, this.eventTrack, this.distanceKmFromEvent);

  @override
  _EventVoteButtonState createState() => _EventVoteButtonState();
}

class _EventVoteButtonState extends State<EventVoteButton> {
  bool isPublic;
  bool isAdmin;
  bool hasVoteRights;
  bool canVote;
  bool userHasVoted;
  List<String> eventUpVotesUids = [];
  String uid;

  bool checkRestrictions() {
    var settings = widget.event.settings;
    if (settings?.isTimeRestrictionEnabled == true) {
      var now = DateTime.now();
      var startDate = settings?.voteRestrictions?.startDate;
      var endDate = settings?.voteRestrictions?.endDate;
      var hasNotStartedYet = startDate != null && now.isBefore(startDate);
      var isFinished = endDate != null && now.isAfter(endDate);
      if (hasNotStartedYet || isFinished) return false;
    }
    if (settings?.isLocationRestrictionEnabled == true) {
      if (widget.distanceKmFromEvent == null ||
          widget.distanceKmFromEvent > 0.2) return false;
    }
    return true;
  }

  @override
  void initState() {
    uid = FirebaseAuth.instance.currentUser.uid;

    eventUpVotesUids = widget.eventTrack.upVotesUids;
    isPublic = widget.event.isPublic;
    isAdmin = widget.event.adminUserId == uid;
    hasVoteRights = isAdmin ||
            (widget.event.usersRights != null &&
                widget.event.usersRights[uid]?.vote == true)
        ? true
        : false;
    var areRestrictionsFulFilled = checkRestrictions();
    canVote = (isPublic || hasVoteRights) && areRestrictionsFulFilled;
    userHasVoted = eventUpVotesUids.indexOf(uid) >= 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return canVote == false
        ? Container()
        : Wrap(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: eventUpVotesUids.length == 0 ? 0 : -12,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_upward),
                color: userHasVoted
                    ? Theme.of(context).accentColor
                    : Theme.of(context).colorScheme.secondary,
                onPressed: () async {
                  runZonedGuarded(() async {
                    List<String> updatedVotes;
                    if (userHasVoted) {
                      updatedVotes = await EventsCollection().downvoteTrack(
                          widget.event.id, widget.eventTrack.id, uid);
                    } else {
                      updatedVotes = await EventsCollection().upvoteTrack(
                          widget.event.id, widget.eventTrack.id, uid);
                    }
                    if (updatedVotes != null) {
                      // widget.setVotesUids(updatedVotes);
                    }
                  }, (error, stackTrace) {
                    FirebaseCrashlytics.instance.recordError(error, stackTrace);
                  });
                },
              ),
              eventUpVotesUids.length == 0
                  ? Container()
                  : Text(
                      '+ ${eventUpVotesUids.length}',
                      style: TextStyle(
                        color: userHasVoted
                            ? Theme.of(context).accentColor
                            : Theme.of(context).colorScheme.secondary,
                        fontSize:
                            Theme.of(context).textTheme.subtitle2.fontSize,
                      ),
                    ),
            ],
          );
  }
}
