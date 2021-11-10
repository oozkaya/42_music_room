import 'dart:async';

import 'package:MusicRoom42/providers/spotify_app_provider.dart';
import 'package:MusicRoom42/services/spotify/api/track.dart';
import 'package:MusicRoom42/ui/musicroom/players/queue_screen.dart';
import 'package:MusicRoom42/utils/spotify/joinArtistsName.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/artist.dart';

import '../../../providers/spotify_player_provider.dart';
import './CustomMarquee.dart';

class PlayerInfosWidget extends StatefulWidget {
  @override
  _PlayerInfosWidgetState createState() => _PlayerInfosWidgetState();
}

class _PlayerInfosWidgetState extends State<PlayerInfosWidget> {
  SpotifyRemoteAppProvider remoteAppProvider;
  SpotifyPlayerProvider playerProvider;

  @override
  void initState() {
    super.initState();
    remoteAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);
    playerProvider = Provider.of<SpotifyPlayerProvider>(context, listen: false);
    var spotifyApi = remoteAppProvider.spotifyApi;
    var trackId = playerProvider.getTrackId();
    isTrackSaved(spotifyApi, trackId)
        .then((value) => playerProvider.setIsLiked(value));
  }

  @override
  Widget build(BuildContext context) {
    Widget _favoriteIcon = Selector<SpotifyPlayerProvider, bool>(
      selector: (_, model) => model?.isLiked,
      builder: (_, isLiked, __) {
        var spotifyApi = remoteAppProvider.spotifyApi;
        String trackId = playerProvider.getTrackId();
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              icon: isLiked
                  ? Icon(
                      LineIcons.heartAlt,
                      color: Colors.green,
                    )
                  : Icon(
                      LineIcons.heart,
                      color: Colors.grey.shade400,
                    ),
              iconSize: 30,
              onPressed: () {
                runZonedGuarded(() {
                  isLiked
                      ? unsaveTrack(spotifyApi, trackId)
                      : saveTrack(spotifyApi, trackId);
                  playerProvider.setIsLiked(!isLiked);
                }, (error, stackTrace) {
                  FirebaseCrashlytics.instance.recordError(error, stackTrace);
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.subscriptions),
              iconSize: 30,
              onPressed: () {
                runZonedGuarded(() {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => QueueScreen()));
                }, (error, stackTrace) {
                  FirebaseCrashlytics.instance.recordError(error, stackTrace);
                });
              },
            ),
          ],
        );
      },
    );

    return Container(
      padding: EdgeInsets.only(left: 25, right: 25),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Selector<SpotifyPlayerProvider, String>(
                  selector: (_, model) => model?.track?.name,
                  builder: (_, trackName, __) => CustomMarquee(
                    text: trackName,
                    fontStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: "ProximaNova",
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      wordSpacing: 0.2,
                    ),
                  ),
                ),
                Selector<SpotifyPlayerProvider, List<Artist>>(
                    selector: (_, model) => model?.track?.artists,
                    builder: (_, artists, __) {
                      String artistsName = joinArtistsName(artists);
                      return CustomMarquee(
                        text: artistsName,
                        fontStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontFamily: "ProximaNovaThin",
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.1,
                        ),
                      );
                    })
              ],
            ),
          ),
          _favoriteIcon,
        ],
      ),
    );
  }
}
