import 'package:flutter/material.dart' hide Page;
import 'package:spotify/spotify.dart';

import './t10_track_widget.dart';

class T10Tracks extends StatelessWidget {
  final Page<Track> top10World;

  T10Tracks(this.top10World);
  @override
  Widget build(BuildContext context) {
    List data = top10World.items.toList();

    return Container(
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          SizedBox(
            width: 180,
            child: T10Track(data[0], 0),
          ),
          Table(
            children: [
              TableRow(children: [
                T10Track(data[1], 1),
                T10Track(data[2], 2),
                T10Track(data[3], 3)
              ]),
              TableRow(children: [
                T10Track(data[4], 4),
                T10Track(data[5], 5),
                T10Track(data[6], 6)
              ]),
              TableRow(children: [
                T10Track(data[7], 7),
                T10Track(data[8], 8),
                T10Track(data[9], 9)
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
