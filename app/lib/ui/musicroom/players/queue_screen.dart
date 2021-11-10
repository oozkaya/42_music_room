import 'package:MusicRoom42/app_localizations.dart';
import 'package:MusicRoom42/models/_models.dart';
import 'package:MusicRoom42/services/spotify/api/track.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_sdk/models/track.dart' as Sdk;
import 'package:tuple/tuple.dart';

import '../../../providers/spotify_app_provider.dart';
import '../../../providers/spotify_player_provider.dart';
import '../widgets/queue_track_tile.dart';

class QueueScreen extends StatefulWidget {
  @override
  _QueueScreenState createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  SpotifyRemoteAppProvider remoteAppProvider;
  SpotifyPlayerProvider playerProvider;
  List<Track> previousTracks;
  List<Track> nextTracks;
  Track currentTrack;
  int currentTrackIndex;
  // ScrollController _controller = ScrollController();

  @override
  void initState() {
    remoteAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);
    super.initState();
  }

  List<Widget> getTrackTiles(List<Track> tracks,
      {bool isCurrentTrack = false, int startIndexAt = 0}) {
    List<Widget> listTiles = [];
    tracks.asMap().forEach((index, track) {
      var tile = QueueTrackTile(
        null,
        track,
        TypeSearch.track,
        showImage: true,
        isCurrentTrack: isCurrentTrack,
        index: index + startIndexAt,
      );
      listTiles.add(tile);
    });
    return listTiles;
  }

  List<Widget> getListWidgets() {
    return [
      ...getTrackTiles(previousTracks, startIndexAt: -previousTracks.length),
      previousTracks.isEmpty
          ? Container()
          : Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Opacity(
                    opacity: 0.7,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 5,
                      children: [
                        Text(AppLocalizations.of(context)
                            .translate('previousTracks')),
                        Icon(Icons.arrow_upward),
                      ],
                    ),
                  )),
            ),
      ...getTrackTiles([currentTrack], isCurrentTrack: true),
      nextTracks.isEmpty
          ? Container()
          : Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
              child: Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 5,
                    children: [
                      Text(
                          AppLocalizations.of(context).translate('nextTracks')),
                      Icon(Icons.arrow_downward),
                    ],
                  )),
            ),
      ...getTrackTiles(nextTracks, startIndexAt: 1),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('queue')),
      ),
      body: Selector<SpotifyPlayerProvider,
          Tuple3<List<Track>, List<Track>, Sdk.Track>>(
        selector: (_, model) =>
            Tuple3(model?.trackHistory, model?.queue, model?.track),
        builder: (_, data, __) {
          previousTracks = data.item1 ?? [];
          nextTracks = data.item2 ?? [];
          Sdk.Track currentTrackSdk = data.item3;

          currentTrackIndex = previousTracks.length;

          if (currentTrackSdk == null) {
            return ListView(
              children: getListWidgets(),
            );
          }

          return FutureBuilder(
            future: getTrack(remoteAppProvider.spotifyApi, null,
                trackUri: currentTrackSdk?.uri ?? ''),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              } else {
                currentTrack = snapshot.data;
                return ListView(
                  children: getListWidgets(),
                );
              }
            },
          );
        },
      ),
    );
  }
}
