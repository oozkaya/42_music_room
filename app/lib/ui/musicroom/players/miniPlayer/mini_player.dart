import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/artist.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/track.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:tuple/tuple.dart';

import '../../../../services/realtime_database/databases/common.dart';
import '../../../../services/spotify/player_state.dart';
import '../../../../services/spotify/api/track.dart';
import '../../../../utils/spotify/joinArtistsName.dart';
import '../../../../providers/spotify_app_provider.dart';
import '../../../../providers/spotify_player_provider.dart';
import '../../../../routes.dart';
import '../../../../services/spotify/player_basics.dart';
import '../../../../ui/musicroom/players/CustomMarquee.dart';

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    @required RenderBox parentBox,
    Offset offset = Offset.zero,
    @required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class MiniPlayer extends StatefulWidget {
  @override
  _MiniPlayerState createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> with WidgetsBindingObserver {
  SpotifyRemoteAppProvider remoteAppProvider;
  SpotifyPlayerProvider playerProvider;
  bool playEnabled;
  Color playColor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    remoteAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);
    playerProvider = Provider.of<SpotifyPlayerProvider>(context, listen: false);
    playEnabled = true;
    Future.delayed(Duration.zero, () {
      playColor = Theme.of(context).textTheme.bodyText2.color;
    });

    var spotifyApi = remoteAppProvider.spotifyApi;
    var trackId = playerProvider.getTrackId();
    isTrackSaved(spotifyApi, trackId)
        .then((value) => playerProvider.setIsLiked(value));
  }

  void enablePlayButton() {
    setState(() {
      playEnabled = true;
      playColor = Theme.of(context).textTheme.bodyText2.color;
    });
  }

  void disablePlayButton() {
    setState(() {
      playEnabled = false;
      playColor = Colors.grey.shade700;
    });
  }

  _openPlayerScreen(BuildContext context) {
    Navigator.of(context).pushNamed(Routes.musicroom_player);
  }

  @override
  Widget build(BuildContext context) {
    Widget _slider = Selector<SpotifyPlayerProvider, Track>(
      selector: (_, model) => model.track,
      builder: (_, track, __) {
        return track == null
            ? Container()
            : Container(
                height: 1.5,
                width: double.infinity,
                padding: const EdgeInsets.all(0),
                child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Theme.of(context).colorScheme.onPrimary,
                      trackShape: CustomTrackShape(),
                      trackHeight: 0.1,
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 0,
                      ),
                    ),
                    child: Selector<SpotifyPlayerProvider, int>(
                      selector: (_, model) => model?.playbackPosition,
                      builder: (_, position, __) {
                        position = track != null &&
                                position >= 0 &&
                                position <= track.duration
                            ? position
                            : 0;
                        return Slider(
                          value: position.toDouble(),
                          min: 0.0,
                          max: track?.duration?.toDouble() ?? 1,
                          onChanged: (_) {},
                        );
                      },
                    )),
              );
      },
    );

    Widget _songImage = Selector<SpotifyPlayerProvider, ImageUri>(
        selector: (_, model) => model?.track?.imageUri,
        builder: (_, imageUri, __) {
          return Container(
            child: FutureBuilder<Uint8List>(
                future: SpotifySdk.getImage(
                  imageUri: imageUri,
                  dimension: ImageDimension.small,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData && !snapshot.hasError) {
                    return Image.memory(snapshot.data, gaplessPlayback: true);
                    // } else if (snapshot.hasError) {
                    //   setStatus('getImage: ', message: snapshot.error.toString());
                    //   return SizedBox(
                    //     width: ImageDimension.small.value.toDouble(),
                    //     height: ImageDimension.small.value.toDouble(),
                    //     child: Icon(Icons.music_note_outlined),
                    //   );
                  }
                  return Center(child: CircularProgressIndicator());
                }),
            height: 65,
            width: 65,
          );
        });

    Widget _songInfos = Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Selector<SpotifyPlayerProvider, String>(
              selector: (_, model) => model?.track?.name,
              builder: (_, trackName, __) => CustomMarquee(
                text: trackName ?? '',
                fontStyle: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Selector<SpotifyPlayerProvider, List<Artist>>(
                selector: (_, model) => model?.track?.artists,
                builder: (_, artists, __) {
                  String artistsName = joinArtistsName(artists);
                  return CustomMarquee(
                    text: artistsName,
                    fontStyle: Theme.of(context).textTheme.bodyText1,
                  );
                }),
          ],
        ),
      ),
    );
    // );

    Widget _favoriteIcon = Selector<SpotifyPlayerProvider, bool>(
      selector: (_, model) => model?.isLiked,
      builder: (_, isLiked, __) {
        var spotifyApi = remoteAppProvider.spotifyApi;
        String trackId = playerProvider.getTrackId();

        return Container(
          width: 35,
          child: IconButton(
            icon: isLiked
                ? Icon(
                    LineIcons.heartAlt,
                    color: Colors.green,
                  )
                : Icon(
                    LineIcons.heart,
                    color: Colors.grey.shade400,
                  ),
            iconSize: 25,
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
        );
      },
    );

    Widget _playIcon =
        Selector<SpotifyPlayerProvider, Tuple4<bool, int, bool, String>>(
      selector: (_, model) => Tuple4(model?.isPaused, model?.playbackPosition,
          model?.isEventAdmin, model?.eventId),
      builder: (_, data, __) {
        bool isPaused = data.item1;
        int position = data.item2;
        bool isEventAdmin = data.item3;
        String eventId = data.item4;
        bool isEvent = eventId != null;

        if (isEvent) {
          playEnabled = isEventAdmin ? playEnabled : false;
          playColor = isEventAdmin && playEnabled
              ? Theme.of(context).textTheme.bodyText2.color
              : Colors.grey.shade700;
        } else {
          playEnabled = true;
          playColor = Theme.of(context).textTheme.bodyText2.color;
          // Future.delayed(Duration.zero, () {
          //   enablePlayButton();
          // });
        }

        return Container(
          margin: const EdgeInsets.only(right: 20),
          width: 35,
          child: IconButton(
            icon: Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              color: playColor,
            ),
            iconSize: 30,
            onPressed: playEnabled
                ? () async {
                    runZonedGuarded(() async {
                      disablePlayButton();
                      isPaused ? await resume() : await pause();
                      playerProvider.setIsPaused(!isPaused);
                      enablePlayButton();
                      await sendIsPaused(playerProvider, !isPaused);
                      if (!isPaused)
                        await sendPosition(playerProvider, position);
                    }, (error, stackTrace) {
                      FirebaseCrashlytics.instance
                          .recordError(error, stackTrace);
                    });
                  }
                : null,
          ),
        );
      },
    );

    Widget _player = Container(
      child: Column(children: [
        _slider,
        Row(
          children: [
            _songImage,
            _songInfos,
            _favoriteIcon,
            _playIcon,
          ],
        ),
      ]),
    );

    return Selector<SpotifyPlayerProvider, Track>(
      selector: (_, model) => model?.track,
      builder: (_, data, __) {
        var track = data;
        return track == null
            ? Container()
            : GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 1)),
                    color: Theme.of(context).bottomAppBarTheme.color,
                  ),
                  child: _player,
                ),
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _openPlayerScreen(context);
                },
              );
      },
    );
  }
}
