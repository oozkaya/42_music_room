import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';

import './tt_track_widget.dart';

class TTTracks extends StatelessWidget {
  final Iterable<Track> topTracks;

  TTTracks(this.topTracks);

  @override
  Widget build(BuildContext context) {
    var data = topTracks.toList();
    int len = data.length;
    var track1 = len >= 1 ? data[0] : null;
    var track2 = len >= 2 ? data[1] : data[0] ?? null;
    var track3 = len >= 3 ? data[2] : data[0] ?? null;
    var track4 = len >= 4 ? data[3] : data[0] ?? null;

    return SizedBox(
      height: 200,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Table(
          children: [
            TableRow(children: [TTTrack(track1), TTTrack(track2)]),
            TableRow(children: [TTTrack(track3), TTTrack(track4)]),
          ],
        ),
      ),
    );
  }
}
