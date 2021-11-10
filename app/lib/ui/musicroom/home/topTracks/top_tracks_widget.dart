import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';

import './tt_header_widget.dart';
import './tt_tracks_widget.dart';

class TopTracks extends StatelessWidget {
  final Iterable<Track> topTracks;

  TopTracks(this.topTracks);

  @override
  Widget build(BuildContext context) {
    return topTracks == null
        ? Container()
        : Container(
            child: Column(
              children: [
                TTHeader(),
                TTTracks(topTracks),
              ],
            ),
          );
  }
}
