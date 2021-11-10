import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../../services/spotify/open_item.dart';

class TAArtist extends StatelessWidget {
  final Artist artist;

  TAArtist(this.artist);

  @override
  Widget build(BuildContext context) {
    final _item = Container(
      height: 70,
      margin: const EdgeInsets.all(4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: Image.network(artist.images.last.url),
            ),
            Container(color: Color.fromRGBO(0, 0, 0, 0.4)),
            Center(
              child: Text(
                artist.name.toUpperCase(), //.replaceAll("", "\u{200B}"),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return InkWell(
        child: _item,
        onTap: () async {
          handleOpenArtist(context, artist.id);
        });
  }
}
