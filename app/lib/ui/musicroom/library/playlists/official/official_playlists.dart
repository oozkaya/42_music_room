import 'package:MusicRoom42/utils/dart/KeepAliveFutureBuilder.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

import '../../../../../app_localizations.dart';
import '../../../../../services/spotify/set_status.dart';
import '../../../../../providers/spotify_app_provider.dart';
import '../../../../../services/spotify/api/playlist.dart';
import '../../../widgets/playlist_tile.dart';
import './create_playlist_screen.dart';
import './liked_songs_screen.dart';

class OfficialPlaylists extends StatefulWidget {
  @override
  _OfficialPlaylistsState createState() => _OfficialPlaylistsState();
}

class _OfficialPlaylistsState extends State<OfficialPlaylists> {
  Widget _likedSongs(BuildContext context) => PlaylistTile(
        name: AppLocalizations.of(context).translate('likedSongs'),
        leading: Container(
          width: 55.0,
          height: 55.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepPurpleAccent[400], Colors.cyan[200]],
            ),
          ),
          child: Icon(LineIcons.heartAlt, size: 30.0),
        ),
        onTap: (ctx) => Navigator.of(ctx)
            .push(MaterialPageRoute(builder: (context) => LikedSongsScreen())),
      );

  @override
  Widget build(BuildContext context) {
    SpotifyRemoteAppProvider remoteAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);

    return KeepAliveFutureBuilder(
      future: getUserPlaylists(remoteAppProvider.spotifyApi),
      builder: (ctx, snapshot) {
        if (snapshot.hasData) {
          var playlists = snapshot.data.toList();
          return ListView(
            key: UniqueKey(),
            children: <Widget>[
              SizedBox(height: 10),
              _likedSongs(context),
              SizedBox(height: 10),
              ...playlists.map((playlist) => PlaylistTile(playlist: playlist)),
            ],
          );
        } else if (snapshot.hasError) {
          setStatus('getUserPlaylists: ', message: snapshot.error.toString());
          return Center(child: Text('Error getting user\'s playlists'));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
