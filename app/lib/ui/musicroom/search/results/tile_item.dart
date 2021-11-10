import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../../app_localizations.dart';
import '../../../../models/_models.dart';
import '../../../../providers/spotify_player_provider.dart';
import '../../../../services/spotify/open_item.dart';
import '../../subpages/item_menu/item_menu.dart';

_getName(item) {
  return Text(
    item['name'] ?? 'Unknown name',
    overflow: TextOverflow.ellipsis,
  );
}

_getSubtitle(item, {BuildContext context, bool showType = true}) {
  String text = '';
  if (item['explicit'] == true) {
    text += "🅴 ";
  }

  if (showType == true) {
    if (item['type'] != null) {
      text = AppLocalizations.of(context).translate(item['type']);
    } else {
      text = 'Unknown type';
    }
  }

  if (item['artists'] != null) {
    List<String> artists = [];
    for (var artist in item['artists']) {
      artists.add(artist['name']);
    }
    if (showType == true) {
      text += ' ⋅ ';
    }
    if (artists.length > 0) {
      text += artists.join(', ');
    }
  }
  return Text(
    text,
    overflow: TextOverflow.ellipsis,
  );
}

_getImage(item) {
  String url;

  try {
    if (item['images'] != null) {
      url = item['images'].last['url'];
    } else if (item['album'] != null) {
      url = item['album']['images'].last['url'];
    }
  } catch (_) {}

  if (url == null) return CircleAvatar(child: Icon(Icons.music_note_outlined));
  if (item['type'] == TypeSearch.artist.key)
    return CircleAvatar(backgroundImage: NetworkImage(url));
  return CircleAvatar(child: Image.network(url));
}

_convertItem(item, TypeSearch type) {
  switch (type) {
    case TypeSearch.album:
      return Album.fromJson(item);
    case TypeSearch.artist:
      return Artist.fromJson(item);
    case TypeSearch.track:
      return Track.fromJson(item);
  }
  return item;
}

class TileItem extends StatelessWidget {
  final dynamic item;
  final TypeSearch type;
  bool showType = true;
  bool forceSubtitle = true;

  TileItem(this.item, this.type, {this.showType, this.forceSubtitle});

  @override
  Widget build(BuildContext context) {
    SpotifyPlayerProvider playerProvider = Provider.of(context, listen: false);

    Text substitle = forceSubtitle == true ||
            type == TypeSearch.album ||
            type == TypeSearch.track
        ? _getSubtitle(item, context: context, showType: this.showType)
        : null;
    return ListTile(
      title: _getName(item),
      subtitle: substitle,
      leading: _getImage(item),
      trailing: item['type'] == TypeSearch.playlist.key
          ? null
          : Container(
              padding: const EdgeInsets.all(0.0),
              width: 30.0,
              child: IconButton(
                icon: Icon(Icons.more_vert),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  runZonedGuarded(() {
                    Navigator.of(context).push(
                        ItemMenu(_convertItem(item, type), type, context));
                  }, (error, stackTrace) {
                    FirebaseCrashlytics.instance.recordError(error, stackTrace);
                  });
                },
              ),
            ),
      onTap: () => openItem(context, playerProvider, item, item['type']),
    );
  }
}
