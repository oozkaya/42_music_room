import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';

import '../../../../app_localizations.dart';
import '../../../../constants/spotify_color_scheme.dart';
import '../../../../providers/spotify_app_provider.dart';
import '../../../../services/spotify/api/playlist.dart';
import '../../../../ui/musicroom/library/library_screen.dart';

enum PlaylistActions { unfollow }

class PlaylistSettings extends StatelessWidget {
  final Playlist playlist;

  PlaylistSettings({
    @required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    SpotifyRemoteAppProvider remoteAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);

    return PopupMenuButton<PlaylistActions>(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[300]
          : Theme.of(context).colorScheme.mediumGray,
      shape: Border(
        left: BorderSide(
          width: 4,
          color: Theme.of(context).accentColor,
          style: BorderStyle.solid,
        ),
      ),
      icon: Icon(Icons.more_vert),
      onSelected: (PlaylistActions result) {
        switch (result) {
          case PlaylistActions.unfollow:
            unfollowPlaylist(remoteAppProvider.spotifyApi, playlist.id);
            Navigator.pop(context);
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => LibraryScreen()));
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<PlaylistActions>>[
        PopupMenuItem<PlaylistActions>(
          value: PlaylistActions.unfollow,
          child:
              Text(AppLocalizations.of(context).translate("playlistUnfollow")),
        ),
      ],
    );
  }
}
