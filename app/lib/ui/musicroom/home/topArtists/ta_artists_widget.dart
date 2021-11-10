import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';

import '../../../../ui/musicroom/home/topArtists/ta_artist_widget.dart';
import './ta_artist_widget.dart';

class TAArtists extends StatelessWidget {
  final Iterable<Artist> topArtists;

  TAArtists(this.topArtists);

  @override
  Widget build(BuildContext context) {
    var data = topArtists.toList();
    int len = data.length;
    var artist1 = len >= 1 ? data[0] : null;
    var artist2 = len >= 2 ? data[1] : data[0] ?? null;
    var artist3 = len >= 3 ? data[2] : data[0] ?? null;
    var artist4 = len >= 4 ? data[3] : data[0] ?? null;

    return SizedBox(
      height: 200,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Table(
          children: [
            TableRow(children: [TAArtist(artist1), TAArtist(artist2)]),
            TableRow(children: [TAArtist(artist3), TAArtist(artist4)]),
          ],
        ),
      ),
    );
  }
}
