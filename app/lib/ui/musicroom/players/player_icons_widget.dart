import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/player_restrictions.dart';
import 'package:tuple/tuple.dart';

import '../../../providers/spotify_player_provider.dart';
import '../../../services/realtime_database/databases/common.dart';
import '../../../services/realtime_database/databases/sessions.dart'
    hide sendPosition, sendIsPaused;
import '../../../services/realtime_database/databases/events.dart'
    hide sendPosition, sendIsPaused;
import '../../../services/spotify/player_repeat_mode.dart';
import '../../../services/spotify/player_basics.dart';

class PlayerIconsWidget extends StatefulWidget {
  @override
  _PlayerIconsWidgetState createState() => _PlayerIconsWidgetState();
}

class _PlayerIconsWidgetState extends State<PlayerIconsWidget> {
  SpotifyPlayerProvider playerProvider;
  bool playEnabled;
  Color playColor;

  @override
  void initState() {
    super.initState();
    playerProvider = Provider.of<SpotifyPlayerProvider>(context, listen: false);
    playEnabled = true;
    playColor = Colors.white;
  }

  Color shuffleButtonColor(bool canToggleShuffle, bool isShuffling) {
    if (canToggleShuffle)
      return isShuffling ? Colors.green : Colors.grey.shade400;
    return Colors.grey.shade700;
  }

  void enablePlayButton() {
    setState(() {
      playEnabled = true;
      playColor = Colors.white;
    });
  }

  void disablePlayButton() {
    setState(() {
      playEnabled = false;
      playColor = Colors.grey.shade700;
    });
  }

  @override
  Widget build(BuildContext context) {
    String userUid = FirebaseAuth.instance.currentUser.uid;

    return Selector<SpotifyPlayerProvider,
        Tuple5<bool, int, PlayerRestrictions, bool, String>>(
      selector: (_, model) => Tuple5(model?.isPaused, model?.playbackPosition,
          model?.playbackRestrictions, model?.isShuffling, model?.sessionId),
      builder: (_, data, __) {
        bool isPaused = data.item1;
        int position = data.item2;
        PlayerRestrictions playbackRestrictions = data.item3;
        bool isShuffling = data.item4;
        String sessionId = data.item5;
        bool isSession = sessionId != null;
        bool isSessionAdmin = playerProvider.isSessionAdmin;
        bool isEventAdmin = playerProvider.isEventAdmin;
        bool isEvent = playerProvider.eventId != null;

        bool canToggleShuffle = playbackRestrictions.canToggleShuffle;
        bool canSkipPrevious = playbackRestrictions.canSkipPrevious;
        bool canSkipNext = playbackRestrictions.canSkipNext;
        bool canRepeatTrack = playbackRestrictions.canRepeatTrack;

        if (isEvent) {
          canToggleShuffle = false;
          canSkipPrevious = false;
          playEnabled = isEventAdmin ? playEnabled : false;
          playColor =
              isEventAdmin && playEnabled ? Colors.white : Colors.grey.shade700;
          canSkipNext = isEventAdmin ? playbackRestrictions.canSkipNext : false;
          canRepeatTrack = false;
        }

        if (isSession) {
          canToggleShuffle = false;
          canSkipPrevious =
              isSessionAdmin ? playbackRestrictions.canSkipPrevious : false;
          canSkipNext =
              isSessionAdmin ? playbackRestrictions.canSkipNext : false;
          canRepeatTrack = false;
        }

        return Container(
          padding: const EdgeInsets.only(left: 22, right: 22),
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  LineIcons.random,
                  color: shuffleButtonColor(canToggleShuffle, isShuffling),
                ),
                onPressed: canToggleShuffle
                    ? () {
                        runZonedGuarded(() {
                          playerProvider.setIsShuffling(!isShuffling);
                        }, (error, stackTrace) {
                          FirebaseCrashlytics.instance
                              .recordError(error, stackTrace);
                        });
                      }
                    : null,
              ),
              IconButton(
                iconSize: 40,
                icon: Icon(
                  Icons.skip_previous,
                  color: canSkipPrevious ? Colors.white : Colors.grey.shade700,
                ),
                onPressed: canSkipPrevious
                    ? () async {
                        runZonedGuarded(() async {
                          await sendMasterUid(sessionId, userUid);
                          playerProvider.setIsSessionMaster(true);
                          if (playerProvider.queue.isNotEmpty) {
                            await playerProvider.queuePrevious();
                          } else {
                            await skipPrevious();
                          }
                          await sendPosition(playerProvider, 0);
                        }, (error, stackTrace) {
                          FirebaseCrashlytics.instance
                              .recordError(error, stackTrace);
                        });
                      }
                    : null,
              ),
              Container(
                height: 90,
                width: 90,
                child: Center(
                  child: IconButton(
                    iconSize: 80,
                    alignment: Alignment.center,
                    icon: (isPaused == true)
                        ? Icon(
                            Icons.play_circle_filled,
                            color: playColor,
                          )
                        : Icon(
                            Icons.pause_circle_filled,
                            color: playColor,
                          ),
                    onPressed: playEnabled
                        ? () async {
                            runZonedGuarded(() async {
                              disablePlayButton();
                              isPaused ? await resume() : await pause();
                              playerProvider.setIsPaused(!isPaused);
                              enablePlayButton();
                              await sendIsPaused(playerProvider, !isPaused);
                              if (!isPaused)
                                await sendPosition(playerProvider, position);
                            }, (error, stackTrace) {
                              FirebaseCrashlytics.instance
                                  .recordError(error, stackTrace);
                            });
                          }
                        : null,
                  ),
                ),
              ),
              IconButton(
                iconSize: 40,
                icon: Icon(
                  Icons.skip_next,
                  color: canSkipNext ? Colors.white : Colors.grey.shade700,
                ),
                onPressed: canSkipNext
                    ? () async {
                        runZonedGuarded(() async {
                          await sendMasterUid(sessionId, userUid);
                          playerProvider.setIsSessionMaster(true);
                          if (playerProvider.queue.isNotEmpty)
                            await playerProvider.queueNext();
                          else if (playerProvider.isEventAdmin == true)
                            await resetSlider(
                                playerProvider, playerProvider.eventId, true);
                          else
                            await skipNext();
                          await sendIsPaused(playerProvider, false);
                          playerProvider.resume();
                        }, (error, stackTrace) {
                          FirebaseCrashlytics.instance
                              .recordError(error, stackTrace);
                        });
                      }
                    : null,
              ),
              IconButton(
                icon: Icon(
                  LineIcons.retweet,
                  color: canRepeatTrack
                      ? Colors.grey.shade400
                      : Colors.grey.shade700,
                ),
                onPressed: canRepeatTrack
                    ? () {
                        runZonedGuarded(() {
                          toggleRepeat();
                        }, (error, stackTrace) {
                          FirebaseCrashlytics.instance
                              .recordError(error, stackTrace);
                        });
                      }
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
