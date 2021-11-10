import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';

import './rp_track_widget.dart';

class RPTracks extends StatelessWidget {
  final Iterable<PlayHistory> recentlyPlayed;

  RPTracks(this.recentlyPlayed);

  @override
  Widget build(BuildContext context) {
    List data = recentlyPlayed.toList();
    return SizedBox(
      height: 200,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: ListView.builder(
          itemCount: data.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (ctx, index) => RPTrack(data[index].track),
        ),
      ),
    );
  }
}
