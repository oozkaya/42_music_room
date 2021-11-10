import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../../providers/spotify_app_provider.dart';
import '../../../../utils/dart/KeepAliveFutureBuilder.dart';
import '../../../../utils/spotify/joinArtistsName.dart';
import '../../../../services/spotify/api/track.dart';
import '../../../../services/spotify/open_item.dart';

class RPTrack extends StatelessWidget {
  final TrackSimple track;

  RPTrack(this.track);

  @override
  Widget build(BuildContext context) {
    SpotifyRemoteAppProvider remoteAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);
    String _albumId;

    KeepAliveFutureBuilder _trackImage(SpotifyApi spotifyApi, String trackId) =>
        KeepAliveFutureBuilder(
          future: getTrack(spotifyApi, trackId),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              _albumId = snapshot.data.album.id;
              String imageUrl = snapshot.data.album.images[1].url;
              return Image(image: NetworkImage(imageUrl));
            }
            return Container();
          },
        );

    String _artistsName = joinArtistsName(track.artists);

    final _item = Column(children: [
      Container(
        margin: const EdgeInsets.all(5),
        child: _trackImage(remoteAppProvider.spotifyApi, track.id),
        height: 100,
        width: 100,
      ),
      Container(
        width: 100,
        child: Column(
          children: [
            Text(
              track?.name, //track.name.replaceAll("", "\u{200B}")
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyText2,
            ),
            Text(
              _artistsName, // _artistsName.replaceAll("", "\u{200B}"),
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
      ),
    ]);

    return InkWell(
        child: _item,
        onTap: () async {
          handleOpenAlbum(context, _albumId);
        });
  }
}
