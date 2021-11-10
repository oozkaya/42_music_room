import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pagination_view/pagination_view.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../../app_localizations.dart';
import '../../../../constants/spotify_color_scheme.dart';
import '../../../../models/_models.dart';
import '../../../../services/spotify/api/playlist.dart';
import '../../../../utils/getImagePalette.dart';
import '../../subpages/playlist/playlist_settings.dart';
import '../../widgets/header_image_medium.dart';
import '../../widgets/track_tile.dart';

class PlaylistScreen extends StatefulWidget {
  final SpotifyApi spotifyApi;
  final String playlistId;

  PlaylistScreen(this.spotifyApi, this.playlistId);

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  Playlist playlist;
  Uint8List playlistImageBytes;
  Color backgroundColor;

  int page;
  GlobalKey<PaginationViewState> key;

  Future<bool> _asyncInit() async {
    playlist = await getPlaylistById(widget.spotifyApi, widget.playlistId);
    var imageUrl =
        playlist.images.isNotEmpty ? playlist.images.first.url : null;
    var palette = await getImagePalette(imgUrl: imageUrl);
    backgroundColor = palette.favorite;
    playlistImageBytes = palette.imageBytes;
    return true;
  }

  @override
  void initState() {
    page = -1;
    key = GlobalKey<PaginationViewState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String _getPlaylistDescription() {
      var formatter = NumberFormat("###,###");
      var total = formatter.format(playlist.followers.total);
      var owner = playlist.owner.displayName;
      String str =
          AppLocalizations.of(context).translate("musicPlaylistDescription");
      str = str.replaceAll("{owner}", owner);
      str = str.replaceAll("{total}", total);
      return str;
    }

    Future<List<dynamic>> pageFetch(int offset) async {
      if (offset == 0) {
        return playlist.tracks.itemsNative;
      }
      var res = await getPlaylistTracksById(widget.spotifyApi, playlist.id,
          limit: 100, offset: offset);
      return res.items.toList();
    }

    return FutureBuilder(
        future: _asyncInit(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Scaffold(
              extendBodyBehindAppBar: false,
              appBar: AppBar(
                title: Text(
                  playlist.name,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                centerTitle: true,
                actions: <Widget>[
                  // IconButton(
                  //   icon: Icon(Icons.more_vert),
                  //   onPressed: () {
                  //     ToastUtils.showCustomToast(context, 'Not implemented');
                  //   },
                  // )
                  PlaylistSettings(
                    playlist: playlist,
                  ),
                ],
              ),
              body: Container(
                child: SizedBox(
                  height: 1000,
                  child: PaginationView(
                    key: key,
                    preloadedItems: [],
                    paginationViewType: PaginationViewType.listView,
                    header: HeaderImageMedium(
                      backgroundColor: backgroundColor ??
                          Theme.of(context).colorScheme.mediumGray,
                      imageBytes: playlistImageBytes,
                      trackContainer: playlist,
                      itemUri: playlist.uri,
                      title: playlist.name,
                      subtitle: _getPlaylistDescription(),
                    ),
                    itemBuilder: (BuildContext context, item, int index) =>
                        TrackTile(
                      playlist,
                      item is Track ? item : PlaylistTrack.fromJson(item).track,
                      TypeSearch.playlist,
                      showImage: true,
                    ),
                    pageFetch: pageFetch,
                    pullToRefresh: false,
                    onError: (dynamic error) => Center(
                      child: Text('Some error occured'),
                    ),
                    onEmpty: Center(
                      child: Text('Empty playlist'),
                    ),
                    bottomLoader: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}
