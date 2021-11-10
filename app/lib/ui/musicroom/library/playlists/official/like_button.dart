import 'dart:async';

import 'package:MusicRoom42/providers/spotify_player_provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/spotify_app_provider.dart';
import '../../../../../services/spotify/api/track.dart';

class LikeButton extends StatefulWidget {
  final String trackId;

  LikeButton(this.trackId);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool isLiked = true;

  @override
  Widget build(BuildContext context) {
    SpotifyRemoteAppProvider remoteAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);
    SpotifyPlayerProvider playerProvider =
        Provider.of<SpotifyPlayerProvider>(context, listen: false);
    var spotifyApi = remoteAppProvider.spotifyApi;

    if (playerProvider.getTrackId() == widget.trackId) {
      return Selector<SpotifyPlayerProvider, bool>(
          selector: (_, model) => model?.isLiked,
          builder: (_, isLiked, __) {
            return IconButton(
              icon: Icon(
                isLiked ? LineIcons.heartAlt : LineIcons.heart,
                size: 30,
                color: isLiked ? Colors.green : Colors.grey.shade400,
              ),
              onPressed: () {
                runZonedGuarded(() {
                  isLiked
                      ? unsaveTrack(spotifyApi, widget.trackId)
                      : saveTrack(spotifyApi, widget.trackId);
                  setState(() {
                    isLiked = !isLiked;
                  });
                  playerProvider.setIsLiked(isLiked);
                }, (error, stackTrace) {
                  FirebaseCrashlytics.instance.recordError(error, stackTrace);
                });
              },
            );
          });
    } else {
      return IconButton(
        icon: Icon(
          isLiked ? LineIcons.heartAlt : LineIcons.heart,
          size: 30,
          color: isLiked ? Colors.green : Colors.grey.shade400,
        ),
        onPressed: () {
          runZonedGuarded(() {
            isLiked
                ? unsaveTrack(spotifyApi, widget.trackId)
                : saveTrack(spotifyApi, widget.trackId);
            setState(() {
              isLiked = !isLiked;
            });
          }, (error, stackTrace) {
            FirebaseCrashlytics.instance.recordError(error, stackTrace);
          });
        },
      );
    }
  }
}
