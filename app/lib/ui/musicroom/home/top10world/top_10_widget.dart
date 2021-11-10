import 'package:flutter/material.dart' hide Page;
import 'package:spotify/spotify.dart';

import './t10_header_widget.dart';
import './t10_tracks_widget.dart';

class Top10World extends StatelessWidget {
  final Page<Track> top10World;

  Top10World(this.top10World);

  @override
  Widget build(BuildContext context) {
    return top10World == null
        ? Container()
        : Container(
            child: Column(
              children: [
                T10Header(),
                T10Tracks(top10World),
              ],
            ),
          );
  }
}
