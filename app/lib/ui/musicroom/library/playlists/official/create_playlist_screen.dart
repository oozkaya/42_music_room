import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';

import '../../../../../app_localizations.dart';
import '../../../../../providers/spotify_app_provider.dart';
import '../../../../../services/spotify/api/playlist.dart';
import '../../../../../ui/musicroom/subpages/playlist/playlist_screen.dart';

class CreatePlaylistScreen extends StatefulWidget {
  @override
  _CreatePlaylistScreenState createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  final _text = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SpotifyRemoteAppProvider remoteAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);

    Widget _title = Text(
      AppLocalizations.of(context).translate('playlistCreateName'),
      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700),
    );

    Widget _input = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: _text,
        maxLength: 30,
        decoration: InputDecoration(counterText: ''),
        onSubmitted: (playlistName) async {
          Playlist playlist = await createPlaylist(
            remoteAppProvider.spotifyApi,
            remoteAppProvider.userId,
            playlistName,
          );
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  PlaylistScreen(remoteAppProvider.spotifyApi, playlist.id)));
        },
      ),
    );

    Widget _cancelButton = TextButton(
      child: Text(
        AppLocalizations.of(context)
            .translate('playlistCreateCancel')
            .toUpperCase(),
        style: TextStyle(color: Colors.white70),
      ),
      onPressed: () {
        runZonedGuarded(() {
          Navigator.pop(context);
        }, (error, stackTrace) {
          FirebaseCrashlytics.instance.recordError(error, stackTrace);
        });
      },
    );

    return SafeArea(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _title,
            SizedBox(height: 50),
            _input,
            SizedBox(height: 50),
            _cancelButton,
          ],
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.grey,
              Colors.black87,
            ],
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}
