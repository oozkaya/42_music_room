import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:spotify/spotify.dart';

import '../../../../app_localizations.dart';
import '../../../../models/_models.dart';
import '../../../../utils/dart/mapIndexed.dart';
import '../../subpages/discography/discography_screen.dart';
import '../../widgets/album_tile.dart';
import '../../widgets/item_card.dart';
import '../../widgets/track_tile.dart';

class ArtistScreenContent extends StatelessWidget {
  final Artist artist;
  final Page<Album> artistAlbums;
  final Page<Album> artistAppearsOn;
  final Iterable<Artist> relatedArtists;
  final Iterable<Track> topTracks;
  final SpotifyApi spotifyApi;

  ArtistScreenContent({
    this.artist,
    this.artistAlbums,
    this.artistAppearsOn,
    this.relatedArtists,
    this.topTracks,
    this.spotifyApi,
  });

  @override
  Widget build(BuildContext context) {
    Widget _categoryTitle(String title) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    List<Widget> _topTracksList() {
      return mapIndexed(
          topTracks.take(5),
          (index, track) => TrackTile(
                artist,
                track,
                TypeSearch.artist,
                showImage: true,
                index: index,
              )).toList();
    }

    Widget _artistAlbums() {
      var firstAlbums =
          artistAlbums.items.take(4).map((album) => AlbumTile(album)).toList();
      var shouldDisplaySeeMoreButton = artistAlbums.items.length > 4;

      return Column(
        children: [
          ...firstAlbums,
          !shouldDisplaySeeMoreButton
              ? Container()
              : SizedBox(
                  height: 25,
                  child: OutlinedButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                    ),
                    child: Text(AppLocalizations.of(context)
                        .translate('musicArtistSeeDiscography')),
                    onPressed: () {
                      runZonedGuarded(() {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DiscographyScreen(
                                  artist.id,
                                  artistAlbums,
                                  spotifyApi,
                                )));
                      }, (error, stackTrace) {
                        FirebaseCrashlytics.instance
                            .recordError(error, stackTrace);
                      });
                    },
                  ),
                ),
        ],
      );
    }

    Widget _relatedArtistsView() {
      var artistsList =
          relatedArtists.take(10).map((artist) => ItemCard(artist)).toList();

      return Container(
        height: 160.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: artistsList,
        ),
      );
    }

    Widget _appearsOnView() {
      if (artistAppearsOn.items.isEmpty) return Container();

      var appearsOnList =
          artistAppearsOn.items.map((item) => ItemCard(item)).toList();
      return Container(
        height: 160.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: appearsOnList,
        ),
      );
    }

    return Column(
      children: [
        _categoryTitle(
            AppLocalizations.of(context).translate('musicArtistPopular')),
        ..._topTracksList(),
        _categoryTitle(AppLocalizations.of(context)
            .translate('musicArtistPopularReleases')),
        _artistAlbums(),
        _categoryTitle(
            AppLocalizations.of(context).translate('musicArtistFansAlsoLike')),
        _relatedArtistsView(),
        _categoryTitle(
            AppLocalizations.of(context).translate('musicArtistAppearsOn')),
        _appearsOnView(),
      ],
    );
  }
}
