import 'package:flutter/material.dart' hide Page;
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../../app_localizations.dart';
import '../../../../models/_models.dart';
import '../../../../providers/spotify_app_provider.dart';
import '../../../../providers/spotify_player_provider.dart';
import '../../../../services/spotify/api/artist.dart';
import '../../../../services/spotify/open_item.dart';

class ItemMenuArtists extends ModalRoute<void> {
  final dynamic item;
  final TypeSearch type;
  List<Artist> artists = List();
  ItemMenuArtists(this.item, this.type);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    SpotifyPlayerProvider playerProvider = Provider.of(context, listen: false);
    SpotifyRemoteAppProvider remoteAppProvider = Provider.of(context);

    return FutureBuilder(
        future: _asyncInit(item, remoteAppProvider.spotifyApi),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Scaffold(
                extendBodyBehindAppBar: false,
                body: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Material(
                    type: MaterialType.transparency,
                    child: SafeArea(
                      child: Column(children: [
                        Spacer(),
                        _getPageName(context),
                        _getMenuRows(artists, context, playerProvider)
                      ]),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ));
          }
        });
  }

  Future<bool> _asyncInit(item, SpotifyApi spotifyApi) async {
    List<Future<void>> futureArtists = List();
    if (item['artists'] != null) {
      for (var artist in item['artists']) {
        futureArtists.add(getArtist(spotifyApi, artist['id'])
            .then((res) => this.artists.add(res)));
      }
    }

    await Future.wait(futureArtists);
    return true;
  }

  _getPageName(BuildContext context) {
    return Container(
      child: Text(
        AppLocalizations.of(context).translate('artists'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
    );
  }

  _getMenuRows(List<Artist> artists, BuildContext context,
      SpotifyPlayerProvider playerProvider) {
    List<Widget> rows = [];
    for (var artist in artists) {
      rows.add(_getArtistLine(artist, context, playerProvider));
    }
    return Container(
      child: Column(
        children: rows,
      ),
    );
  }

  _getArtistLine(Artist artist, BuildContext context,
      SpotifyPlayerProvider playerProvider) {
    return ListTile(
      title: Text(
        artist.name,
        overflow: TextOverflow.ellipsis,
      ),
      leading:
          CircleAvatar(backgroundImage: NetworkImage(artist.images.last.url)),
      onTap: () => openItem(context, playerProvider, artist, artist.type),
    );
  }
}
