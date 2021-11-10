import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';

import './rp_header_widget.dart';
import './rp_tracks_widget.dart';

class RecentlyPlayed extends StatelessWidget {
  final Iterable<PlayHistory> recentlyPlayed;

  RecentlyPlayed(this.recentlyPlayed);

  @override
  Widget build(BuildContext context) {
    return recentlyPlayed == null
        ? Container()
        : Container(
            child: Column(
              children: [
                RPHeader(),
                RPTracks(recentlyPlayed),
              ],
            ),
          );
  }
}
