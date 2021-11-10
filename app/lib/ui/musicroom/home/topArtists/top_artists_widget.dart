import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';

import '../../../../ui/musicroom/home/topArtists/ta_artists_widget.dart';
import '../../../../ui/musicroom/home/topArtists/ta_header_widget.dart';

class TopArtists extends StatelessWidget {
  final Iterable<Artist> topArtists;

  TopArtists(this.topArtists);

  @override
  Widget build(BuildContext context) {
    return topArtists == null
        ? Container()
        : Container(
            child: Column(
              children: [
                TAHeader(),
                TAArtists(topArtists),
              ],
            ),
          );
  }
}
