import 'dart:async';

import 'package:MusicRoom42/models/_models.dart';
import 'package:MusicRoom42/providers/spotify_player_provider.dart';
import 'package:MusicRoom42/services/spotify/api/track.dart';
import 'package:MusicRoom42/ui/musicroom/players/CustomMarquee.dart';
import 'package:MusicRoom42/ui/musicroom/subpages/item_menu/item_menu.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';

class PlayerHeaderWidget extends StatelessWidget {
  final String contextTitle;
  final String contextSubtitle;
  final SpotifyApi spotifyApi;

  PlayerHeaderWidget(
    this.contextTitle,
    this.contextSubtitle, {
    this.spotifyApi,
  });

  Future<Track> init(String uri) async {
    return await getTrack(spotifyApi, null, trackUri: uri);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<SpotifyPlayerProvider, String>(
        selector: (_, model) => model?.track?.uri,
        builder: (_, uri, __) {
          return FutureBuilder(
              future: init(uri),
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        iconSize: 24,
                        icon: Icon(
                          LineIcons.angleDown,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          runZonedGuarded(() {
                            Navigator.of(context).pop();
                          }, (error, stackTrace) {
                            FirebaseCrashlytics.instance.recordError(error, stackTrace);
                          });
                        },
                      ),
                      Expanded(
                        child: Column(
                          children: <Widget>[
                            CustomMarquee(
                              text: contextSubtitle.toUpperCase(),
                              fontStyle: TextStyle(
                                letterSpacing: 1,
                                fontSize: 11,
                                color: Colors.white,
                              ),
                            ),
                            CustomMarquee(
                              text: contextTitle,
                              fontStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontFamily: "ProximaNova",
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        iconSize: 24,
                        icon: Icon(
                          LineIcons.verticalEllipsis,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          runZonedGuarded(() {
                            Navigator.of(context).push(ItemMenu(
                                snapshot.data, TypeSearch.track, context,
                                showArtists: true,
                                showAlbum: true,
                                album: null,
                                isEvent: false,
                                onDelete: null));
                          }, (error, stackTrace) {
                            FirebaseCrashlytics.instance
                                .recordError(error, stackTrace);
                          });
                        },
                      )
                    ],
                  );
                }
                return Container();
              });
        });
  }
}
