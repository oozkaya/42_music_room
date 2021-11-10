import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../../utils/spotify/joinArtistsName.dart';
import '../../../../services/spotify/open_item.dart';

class TTTrack extends StatelessWidget {
  final Track track;

  TTTrack(this.track);

  @override
  Widget build(BuildContext context) {
    String _artistsName = joinArtistsName(track.artists);

    final _item = Container(
      height: 70,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey[850],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Row(
          children: [
            Image.network(track.album.images[1].url),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    track?.name, //.replaceAll("", "\u{200B}"),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _artistsName, //.replaceAll("", "\u{200B}"),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return InkWell(
        child: _item,
        onTap: () async {
          handleOpenAlbum(context, track.album.id);
        });
  }
}
