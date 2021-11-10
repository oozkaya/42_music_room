import 'dart:typed_data';

import 'package:flutter/material.dart' hide Page;
import 'package:intl/intl.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../../app_localizations.dart';
import '../../../../constants/spotify_color_scheme.dart';
import '../../../../services/spotify/api/artist.dart';
import '../../widgets/sliver_header_image_large.dart';
import '../../../../utils/getImagePalette.dart';
import './artist_content.dart';

class ArtistScreen extends StatefulWidget {
  final SpotifyApi spotifyApi;
  final String artistId;

  ArtistScreen(this.spotifyApi, this.artistId);

  @override
  _ArtistScreenState createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  Artist artist;
  Iterable<Artist> relatedArtists;
  Iterable<Track> topTracks;
  Page<Album> artistAlbums;
  Page<Album> artistAppearsOn;
  Color backgroundColor;
  Uint8List artistImageBytes;

  Future<bool> _asyncInit() async {
    await Future.wait([
      getArtist(widget.spotifyApi, widget.artistId).then((res) => artist = res),
      getArtistTopTracks(widget.spotifyApi, widget.artistId)
          .then((res) => topTracks = res),
      getArtistAlbums(widget.spotifyApi, widget.artistId, ['album', 'single'])
          .then((res) => artistAlbums = res),
      getArtistAlbums(widget.spotifyApi, widget.artistId, ['appears_on'])
          .then((res) => artistAppearsOn = res),
      getRelatedArtists(widget.spotifyApi, widget.artistId)
          .then((res) => relatedArtists = res),
    ]);
    var imageUrl = artist.images.isNotEmpty ? artist.images.first.url : null;
    var palette = await getImagePalette(imgUrl: imageUrl);
    backgroundColor = palette.dominant;
    artistImageBytes = palette.imageBytes;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    String _getArtistDescription() {
      var formatter = NumberFormat("###,###");
      var total = formatter.format(artist.followers.total);
      String str =
          AppLocalizations.of(context).translate("musicArtistDescription");
      str = str.replaceAll("{total}", total);
      return str;
    }

    return FutureBuilder(
        future: _asyncInit(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Scaffold(
              extendBodyBehindAppBar: false,
              body: CustomScrollView(
                slivers: <Widget>[
                  SliverPersistentHeader(
                    delegate: SliverHeaderImageLarge(
                        backgroundColor: backgroundColor ??
                            Theme.of(context).colorScheme.mediumGray,
                        imageBytes: artistImageBytes,
                        itemUri: artist.uri,
                        title: artist.name,
                        subtitle: _getArtistDescription(),
                        artist: artist),
                    floating: false,
                    pinned: true,
                  ),
                  SliverToBoxAdapter(
                      child: ArtistScreenContent(
                    artist: artist,
                    artistAlbums: artistAlbums,
                    artistAppearsOn: artistAppearsOn,
                    relatedArtists: relatedArtists,
                    topTracks: topTracks,
                    spotifyApi: widget.spotifyApi,
                  )),
                ],
              ),
            );
          }
        });
  }
}
