import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../../../providers/spotify_app_provider.dart';
import '../../../../../services/spotify/api/user.dart';
import '../../../../../utils/spotify/joinArtistsName.dart';
import '../../../../../app_localizations.dart';
import 'like_button.dart';

class LikedSongsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SpotifyRemoteAppProvider remoteAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);

    Widget _header = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.deepPurpleAccent[400],
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 50),
          Icon(LineIcons.heartAlt, size: 100),
          Text(
            AppLocalizations.of(context).translate('likedSongs'),
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headline4.fontSize,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 70),
        ],
      ),
    );

    Widget _likedSongs(List<TrackSaved> savedTracks) => ListView.builder(
          itemCount: savedTracks.length,
          itemBuilder: (ctx2, index) {
            String _imageUrl = savedTracks[index].track.album.images.last.url;
            String _trackName = savedTracks[index].track.name;
            String _trackId = savedTracks[index].track.id;
            String _artistsName =
                joinArtistsName(savedTracks[index].track.artists);

            return Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Image.network(_imageUrl),
                  title: Text(
                    _trackName,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _artistsName,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: LikeButton(_trackId),
                ),
              ),
            );
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );

    return FutureBuilder(
        future: getLikedSongs(remoteAppProvider.spotifyApi),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          List<TrackSaved> savedTracks = snapshot.data.toList();
          return Scaffold(
            extendBodyBehindAppBar: false,
            appBar: AppBar(backgroundColor: Colors.transparent),
            body: Center(
              child: ListView(
                children: [
                  _header,
                  _likedSongs(savedTracks),
                ],
              ),
            ),
          );
        });
  }
}
