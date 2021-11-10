import 'dart:async';
import 'dart:typed_data';

import 'package:MusicRoom42/services/spotify/api/artist.dart';
import 'package:MusicRoom42/ui/musicroom/widgets/album_tile.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:intl/intl.dart';
import 'package:pagination_view/pagination_view.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../../app_localizations.dart';
import '../../../../constants/spotify_color_scheme.dart';
import '../../../../services/spotify/api/playlist.dart';
import '../../widgets/track_tile.dart';
import '../../../../utils/dart/stringsExtension.dart';
import '../../../utils/toast/toast_utils.dart';
import '../../widgets/header_image_medium.dart';

class DiscographyScreen extends StatefulWidget {
  final String artistId;
  final Page<Album> firstAlbums;
  final SpotifyApi spotifyApi;

  DiscographyScreen(this.artistId, this.firstAlbums, this.spotifyApi);

  @override
  _DiscographyScreenState createState() => _DiscographyScreenState();
}

class _DiscographyScreenState extends State<DiscographyScreen> {
  int page;
  GlobalKey<PaginationViewState> key;

  @override
  void initState() {
    page = -1;
    key = GlobalKey<PaginationViewState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<List<dynamic>> pageFetch(int offset) async {
      if (offset == 0) {
        return widget.firstAlbums.items.toList();
      }
      var res = await getArtistAlbums(
          widget.spotifyApi, widget.artistId, ['album', 'single'],
          limit: 20, offset: offset);
      return res.items.toList();
    }

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('musicDiscographyTitle'),
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              runZonedGuarded(() {
                ToastUtils.showCustomToast(context, 'Not implemented');
              }, (error, stackTrace) {
                FirebaseCrashlytics.instance.recordError(error, stackTrace);
              });
            },
          )
        ],
      ),
      body: Container(
        child: SizedBox(
          height: 1000,
          child: PaginationView(
            key: key,
            preloadedItems: [],
            paginationViewType: PaginationViewType.listView,
            itemBuilder: (BuildContext context, item, int index) =>
                AlbumTile(item),
            pageFetch: pageFetch,
            pullToRefresh: false,
            onError: (dynamic error) => Center(
              child: Text('Some error occured'),
            ),
            onEmpty: Center(
              child: Text('Empty'),
            ),
            bottomLoader: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
