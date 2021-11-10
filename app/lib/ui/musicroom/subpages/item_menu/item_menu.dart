import 'package:flutter/material.dart' hide Page;
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../../app_localizations.dart';
import '../../../../models/_models.dart';
import '../../../../providers/spotify_app_provider.dart';
import '../../../../providers/spotify_player_provider.dart';
import '../../../../services/spotify/api/album.dart';
import '../../../../services/spotify/api/artist.dart';
import '../../../../services/spotify/api/track.dart';
import '../../../../services/spotify/open_item.dart';
import '../../../utils/toast/toast_utils.dart';
import '../../library/library_screen.dart';
import '../../library/events/user_events.dart';
import './item_menu_artists.dart';

class ItemMenu extends ModalRoute {
  final dynamic item;
  final TypeSearch type;
  final bool showArtists;
  final BuildContext context;
  final bool lightArtist;
  final bool showAlbum;
  final Album album;
  final bool isEvent;
  final Function onDelete;

  ItemMenu(this.item, this.type, this.context,
      {this.showArtists,
      this.lightArtist,
      this.showAlbum,
      this.album,
      this.isEvent,
      this.onDelete});

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Theme.of(context).scaffoldBackgroundColor;

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

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: _content(context, playerProvider, remoteAppProvider.spotifyApi),
      ),
    );
  }

  Widget build(
    BuildContext context,
  ) {
    SpotifyPlayerProvider playerProvider = Provider.of(context, listen: false);
    SpotifyRemoteAppProvider remoteAppProvider = Provider.of(context);

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: _content(context, playerProvider, remoteAppProvider.spotifyApi),
      ),
    );
  }

  _getImage(item, TypeSearch type) {
    String url;

    try {
      if (type != TypeSearch.track && item.images != null) {
        url = item.images[1].url;
      } else if (item.album != null) {
        url = item.album.images[1].url;
      }
    } catch (_) {}
    try {
      if (url == null && this.album != null) {
        if (this.album.images != null) {
          url = this.album.images[1].url;
        }
      }
    } catch (_) {}

    if (url == null) return Container();

    Column col = Column(
      children: [
        Image.network(url, height: 150, fit: BoxFit.fill),
        _getName(item)
      ],
    );
    if (this.type == TypeSearch.album || this.type == TypeSearch.track) {
      col.children.add(_getArtistsName(item));
    }
    return col;
  }

  _getName(item) {
    return Container(
      child: Text(
        item.name ?? '',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
    );
  }

  _getArtistsName(item) {
    String text = '';
    if (item.artists != null) {
      List<String> artists = [];
      for (var artist in item.artists) {
        artists.add(artist.name);
      }
      if (artists.length > 0) {
        text += artists.join(', ');
      }
    }
    return Container(
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
    );
  }

  _getMenuRows(item, BuildContext context, SpotifyPlayerProvider playerProvider,
      SpotifyApi spotifyApi) {
    List<Widget> rows = [];
    if (this.type == TypeSearch.track || this.type == TypeSearch.album) {
      rows.add(ListTile(
          title: Text(
            AppLocalizations.of(context).translate('itemMenuLike'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: Icon(
            Icons.favorite_border,
            color: Theme.of(context).iconTheme.color,
          ),
          onTap: () => ToastUtils.showCustomToast(context, 'Not implemented')));
      rows.add(
        ListTile(
          title: Text(
            AppLocalizations.of(context)
                .translate('itemMenuAddToPlaylistEvent'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: Icon(
            Icons.music_note_outlined,
            color: Theme.of(context).iconTheme.color,
          ),
          onTap: () => getTrack(spotifyApi, item.id).then(
            (track) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LibraryScreen(
                  addTrackScreen: true,
                  track: track,
                  onAdd: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ),
      );
      if (this.onDelete != null) {
        rows.add(ListTile(
            title: Text(
              AppLocalizations.of(context).translate('itemMenuRemoveTrack'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: Icon(
              Icons.delete,
              color: Theme.of(context).iconTheme.color,
            ),
            onTap: () {
              this.onDelete();
              Navigator.of(context).pop();
            }));
      }
      if (this.type == TypeSearch.album) {
        rows.add(ListTile(
            title: Text(
              AppLocalizations.of(context).translate('itemMenuLikeAll'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: Icon(
              Icons.favorite_border_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            onTap: () =>
                ToastUtils.showCustomToast(context, 'Not implemented')));
      }
      rows.add(ListTile(
          title: Text(
            AppLocalizations.of(context).translate('itemMenuAddToQueue'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: Icon(
            Icons.queue_music_outlined,
            color: Theme.of(context).iconTheme.color,
          ),
          onTap: () => ToastUtils.showCustomToast(context, 'Not implemented')));
      if (this.type == TypeSearch.track && this.showAlbum != false) {
        rows.add(ListTile(
            title: Text(
              AppLocalizations.of(context).translate('itemMenuShowAlbum'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: Icon(
              Icons.adjust_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
            onTap: () => getAlbum(spotifyApi, item.album.id).then((album) =>
                openItem(context, playerProvider, album, album.type))));
      }
      if (this.showArtists != false) {
        if (item.artists.length == 1) {
          rows.add(ListTile(
              title: Text(
                AppLocalizations.of(context).translate('itemMenuShowArtist'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: Icon(
                Icons.perm_identity_outlined,
                color: Theme.of(context).iconTheme.color,
              ),
              onTap: () => getArtist(spotifyApi, item.artists[0].id).then(
                  (artist) =>
                      openItem(context, playerProvider, artist, artist.type))));
        } else if (item.artists.length > 1) {
          rows.add(ListTile(
              title: Text(
                AppLocalizations.of(context).translate('itemMenuShowArtists'),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              leading: Icon(
                Icons.supervisor_account,
                color: Theme.of(context).iconTheme.color,
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(ItemMenuArtists(item, type));
              }));
        }
      }
    }
    rows.add(ListTile(
        title: Text(
          AppLocalizations.of(context).translate('itemMenuShare'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Icon(
          Icons.share_outlined,
          color: Theme.of(context).iconTheme.color,
        ),
        onTap: () => ToastUtils.showCustomToast(context, 'Not implemented')));
    String radioKey = '';
    if (this.type == TypeSearch.artist) {
      radioKey = 'itemMenuArtistRadio';
    } else if (this.type == TypeSearch.track) {
      radioKey = 'itemMenuTrackRadio';
    } else if (this.type == TypeSearch.album) {
      radioKey = 'itemMenuAlbumRadio';
    }
    rows.add(ListTile(
        title: Text(
          AppLocalizations.of(context).translate(radioKey),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Icon(
          Icons.wifi_tethering,
          color: Theme.of(context).iconTheme.color,
        ),
        onTap: () => ToastUtils.showCustomToast(context, 'Not implemented')));
    if ((this.type == TypeSearch.artist && this.showArtists != true) ||
        this.type == TypeSearch.album) {
      rows.add(ListTile(
          title: Text(
            AppLocalizations.of(context).translate('itemMenuAddHome'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: Icon(
            Icons.smartphone,
            color: Theme.of(context).iconTheme.color,
          ),
          onTap: () => ToastUtils.showCustomToast(context, 'Not implemented')));
    }
    return Container(
      child: Column(
        children: rows,
      ),
    );
  }

  _content(BuildContext context, SpotifyPlayerProvider playerProvider,
      SpotifyApi spotifyApi) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        body: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 30.0, 0, 0),
                    child: Column(
                        //mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _getImage(item, type),
                          _getMenuRows(
                              item, context, playerProvider, spotifyApi)
                        ]),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          );
        }));
  }
}
