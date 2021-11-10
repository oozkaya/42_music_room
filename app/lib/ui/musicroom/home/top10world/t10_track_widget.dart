import 'package:flutter/material.dart';

import '../../../../utils/spotify/joinArtistsName.dart';
import '../../../../services/spotify/open_item.dart';
import 'package:spotify/spotify.dart' hide Image;

class T10Track extends StatelessWidget {
  final Track track;
  final int index;

  T10Track(this.track, this.index);

  @override
  Widget build(BuildContext context) {
    Widget _image = Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(track.album.images[1].url),
        ),
        Positioned(
          // left: 5,
          // top: 5,
          child: Container(
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomRight: Radius.circular(20),
              ),
            ),
            constraints: BoxConstraints(minWidth: 30, minHeight: 30),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );

    Widget _trackName = Text(
      track?.name, //.replaceAll("", "\u{200B}"),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );

    String _artistsName = joinArtistsName(track?.artists);
    Widget _trackArtists = Text(
      _artistsName, //.replaceAll("", "\u{200B}"),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: 12, color: Theme.of(context).textTheme.bodyText1.color),
    );

    final _item = Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          _image,
          SizedBox(height: 10),
          _trackName,
          _trackArtists,
        ],
      ),
    );

    return InkWell(
        child: _item,
        onTap: () async {
          handleOpenAlbum(context, track.album.id);
        });
  }
}
