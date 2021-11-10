import 'package:MusicRoom42/services/realtime_database/databases/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/player_restrictions.dart';
import 'package:spotify_sdk/models/track.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:tuple/tuple.dart';

import '../../../providers/spotify_player_provider.dart';
import '../../../services/spotify/player_state.dart';
// import '../../../services/realtime_database/databases/sessions.dart';
import '../../../services/realtime_database/databases/common.dart';

class PlayerSliderWidget extends StatefulWidget {
  @override
  _PlayerSliderWidgetState createState() => _PlayerSliderWidgetState();
}

class _PlayerSliderWidgetState extends State<PlayerSliderWidget> {
  SpotifyPlayerProvider playerProvider;

  @override
  void initState() {
    super.initState();
    playerProvider = Provider.of<SpotifyPlayerProvider>(context, listen: false);
  }

  int getMinutes(int milliseconds) {
    if (milliseconds == null) milliseconds = 0;
    double minutes = (milliseconds / (1000 * 60)) % 60;
    return minutes.toInt();
  }

  String getSeconds(int milliseconds) {
    if (milliseconds == null) milliseconds = 0;
    double seconds = (milliseconds / 1000) % 60;
    return seconds.toInt().toString().padLeft(2, "0");
  }

  @override
  Widget build(BuildContext context) {
    return Selector<SpotifyPlayerProvider,
        Tuple4<Track, int, PlayerRestrictions, bool>>(
      selector: (_, model) => Tuple4(model?.track, model?.playbackPosition,
          model?.playbackRestrictions, model?.isEventAdmin),
      builder: (_, data, __) {
        Track track = data.item1;
        int position = data.item2 ?? 0;
        PlayerRestrictions playbackRestrictions = data.item3;
        bool isEventAdmin = data.item4;
        bool isEvent = playerProvider.eventId != null;
        bool canSeek =
            playbackRestrictions != null && playbackRestrictions.canSeek;
        int duration;

        if (track == null)
          getPlayerState()
              .then((state) => playerProvider.setPlayerState(state));

        position = track != null && position >= 0 && position <= track?.duration
            ? position
            : 0;
        duration = track?.duration ?? 0;

        if (isEvent)
          canSeek = isEventAdmin && playbackRestrictions != null
              ? playbackRestrictions.canSeek
              : false;

        return Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 5, right: 5),
              width: double.infinity,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade600,
                  activeTickMarkColor: Colors.white,
                  thumbColor: Colors.white,
                  trackHeight: 3,
                  thumbShape: RoundSliderThumbShape(
                    enabledThumbRadius: canSeek ? 4 : 0,
                  ),
                ),
                child: Slider(
                  value: position.toDouble(),
                  min: 0.0,
                  max: duration.toDouble(),
                  onChanged: canSeek
                      ? (double pickedValue) {
                          playerProvider.stopTimer();
                          playerProvider.setPosition(pickedValue.toInt());
                        }
                      : null,
                  onChangeEnd: (double pickedValue) async {
                    int position = pickedValue.toInt();
                    await SpotifySdk.seekTo(positionedMilliseconds: position);
                    await sendPosition(playerProvider, position);
                    playerProvider.initTimer();
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${getMinutes(position)}:${getSeconds(position)}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: 'ProximaNovaThin',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${getMinutes(duration)}:${getSeconds(duration)}',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: 'ProximaNovaThin',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
