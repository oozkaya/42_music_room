import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../../constants/spotify_color_scheme.dart';
import '../../../../models/_models.dart';
import '../../../../services/spotify/api/album.dart';
import '../../../../utils/getImagePalette.dart';
import '../../../../utils/spotify/joinArtistsName.dart';
import '../../subpages/item_menu/item_menu.dart';
import '../../widgets/header_image_medium.dart';
import '../../widgets/track_tile.dart';

class AlbumScreen extends StatefulWidget {
  final String albumId;
  final SpotifyApi spotifyApi;

  AlbumScreen(this.spotifyApi, this.albumId);

  @override
  _AlbumScreenState createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  Album album;
  Color backgroundColor;
  Uint8List albumImageBytes;

  Future<bool> _asyncInit() async {
    album = await getAlbum(widget.spotifyApi, widget.albumId);
    var imageUrl = album.images.isNotEmpty ? album.images[1].url : null;
    var palette = await getImagePalette(imgUrl: imageUrl);
    backgroundColor = palette.favorite;
    albumImageBytes = palette.imageBytes;
    return true;
  }

  String _getAlbumDescription() {
    var artists = joinArtistsName(album.artists);
    var dateFormatters = {
      'DatePrecision.year': "yyyy",
      'DatePrecision.month': "yyyy-MM",
      'DatePrecision.day': "yyyy-MM-dd",
    };
    var formatter = dateFormatters[album.releaseDatePrecision.toString()];
    var releaseDate = DateFormat(formatter).parse(album.releaseDate);
    return "$artists • ${releaseDate.year}";
  }

  List<Widget> _trackList() {
    return album.tracks
        .map((track) => TrackTile(album, track, TypeSearch.album))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _asyncInit(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: Text(
                  album.name,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                centerTitle: true,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      runZonedGuarded(() {
                        Navigator.of(context).push(
                            ItemMenu(this.album, TypeSearch.album, context));
                      }, (error, stackTrace) {
                        FirebaseCrashlytics.instance
                            .recordError(error, stackTrace);
                      });
                    },
                  )
                ],
              ),
              body: Container(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: <Widget>[
                    HeaderImageMedium(
                      backgroundColor: backgroundColor ??
                          Theme.of(context).colorScheme.mediumGray,
                      imageBytes: albumImageBytes,
                      trackContainer: album,
                      itemUri: album.uri,
                      title: album.name,
                      subtitle: _getAlbumDescription(),
                    ),
                    ..._trackList(),
                  ],
                ),
              ),
            );
          }
        });
  }
}
