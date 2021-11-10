import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:MusicRoom42/providers/spotify_player_provider.dart';
import 'package:MusicRoom42/services/spotify/open_item.dart';

class ItemCard extends StatelessWidget {
  final dynamic item;

  ItemCard(this.item);

  @override
  Widget build(BuildContext context) {
    SpotifyPlayerProvider playerProvider =
        Provider.of<SpotifyPlayerProvider>(context);

    return InkWell(
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 100,
              width: 100,
              child: ClipRRect(
                child: Image.network(item.images[1].url, fit: BoxFit.cover),
                borderRadius:
                    BorderRadius.circular(item.type == 'artist' ? 100 : 0),
              ),
            ),
            SizedBox(height: 5),
            RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              text: TextSpan(
                text: item.name,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        height: 100,
        width: 100,
      ),
      onTap: () => openItem(context, playerProvider, item, item.type),
    );
  }
}
