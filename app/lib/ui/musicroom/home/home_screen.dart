import 'package:flutter/material.dart' hide Page;
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';

import '../../../providers/spotify_app_provider.dart';
import '../../../services/spotify/api/playlist.dart';
import '../../../services/spotify/api/user.dart';
import '../../../utils/dart/KeepAliveFutureBuilder.dart';
import './topArtists/top_artists_widget.dart';
import './topTracks/top_tracks_widget.dart';
import './recentlyPlayed/recently_played_widget.dart';
import './top10world/top_10_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Page<Track> top10World;
  Iterable<Artist> topArtists;
  Iterable<Track> topTracks;
  Iterable<PlayHistory> recentlyPlayed;

  Future<bool> _asyncInit(SpotifyApi spotifyApi) async {
    await Future.wait([
      getTopArtists(spotifyApi).then((res) => topArtists = res),
      getTopTracks(spotifyApi).then((res) => topTracks = res),
      getRecentlyPlayed(spotifyApi).then((res) => recentlyPlayed = res),
      getPlaylistTracksById(
        spotifyApi,
        "37i9dQZEVXbMDoHDwVN2tF", // Global Top 50
        limit: 10,
      ).then((res) => top10World = res),
    ]);
    return true;
  }

  List<Widget> widgetsList() => [
        TopArtists(topArtists),
        TopTracks(topTracks),
        RecentlyPlayed(recentlyPlayed),
        Top10World(top10World)
      ];

  @override
  Widget build(BuildContext context) {
    final spotifyAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);

    return KeepAliveFutureBuilder(
        future: _asyncInit(spotifyAppProvider.spotifyApi),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return ListView(children: widgetsList());
          }
        });
  }
}
