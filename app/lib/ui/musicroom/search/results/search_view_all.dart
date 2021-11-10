import 'dart:async';

import 'package:MusicRoom42/services/firestore/collections/collabs_collection.dart';
import 'package:MusicRoom42/services/firestore/collections/events_collection.dart';
import 'package:MusicRoom42/ui/musicroom/search/results/tile_item.dart';
import 'package:MusicRoom42/ui/musicroom/widgets/collab_tile.dart';
import 'package:MusicRoom42/ui/musicroom/widgets/event_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart' hide Page;
import 'package:pagination_view/pagination_view.dart';
import 'package:spotify/spotify.dart';

import '../../../../app_localizations.dart';
import '../../../../models/_models.dart';
import '../../../../services/spotify/api/search.dart';
import '../../../../providers/spotify_app_provider.dart';
import '../../../utils/toast/toast_utils.dart';

class SearchViewAllScreen extends StatefulWidget {
  final String query;
  final TypeSearch type;
  SearchViewAllScreen(this.query, this.type);

  @override
  _SearchViewAllScreenState createState() =>
      _SearchViewAllScreenState(this.query, this.type);
}

class _SearchViewAllScreenState extends State<SearchViewAllScreen> {
  int page;
  GlobalKey<PaginationViewState> key;
  final String query;
  final TypeSearch type;
  _SearchViewAllScreenState(this.query, this.type);
  ReadableCollabsResults lastCollabsResults;
  ReadableEventsResults lastEventsResults;

  @override
  void initState() {
    page = -1;
    key = GlobalKey<PaginationViewState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SpotifyRemoteAppProvider remoteAppProvider = Provider.of(context);
    var userId = FirebaseAuth.instance.currentUser.uid;

    getSearchResultsByType(TypeSearch type, dynamic searchResult) {
      if (searchResult == null) return [];

      for (var pages in searchResult) {
        var firstItem = pages?.metadata?.itemsNative
            ?.firstWhere((item) => item != null, orElse: () => null);
        var firstItemType = firstItem != null ? firstItem['type'] : null;
        if (firstItemType == type.key) return pages.metadata.itemsNative;
      }
      return [];
    }

    Future<List<dynamic>> pageFetch(int offset) async {
      if (this.query.length > 0) {
        if (this.type == TypeSearch.collab) {
          var res = await CollabsCollection().searchReadableByUserId(
            userId,
            query,
            lastResults: lastCollabsResults,
            limit: 10,
          );
          lastCollabsResults = res;
          return res.docs;
        } else if (this.type == TypeSearch.event) {
          var res = await EventsCollection().searchReadableByUserId(
            userId,
            query,
            lastResults: lastEventsResults,
            limit: 10,
          );
          lastEventsResults = res;
          return res.docs;
        } else {
          var res = await search(remoteAppProvider.spotifyApi,
              q: this.query,
              limit: 20,
              offset: offset,
              types: [SearchType(this.type.key)]);
          return getSearchResultsByType(this.type, res);
        }
      }
      return [];
    }

    final Map<String, dynamic> translateValues = {
      'category': '',
      'value': query
    };
    String key;
    switch (type) {
      case TypeSearch.album:
        key = 'albums';
        break;
      case TypeSearch.artist:
        key = 'artists';
        break;
      case TypeSearch.playlist:
        key = 'playlists';
        break;
      case TypeSearch.track:
        key = 'tracks';
        break;
      case TypeSearch.collab:
        key = 'collabs';
        break;
      case TypeSearch.event:
        key = 'events';
        break;
    }
    translateValues.update('category',
        (value) => AppLocalizations.of(context).translate(key).toLowerCase());

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)
              .translate('searchWordIn', translateValues),
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
      body: Center(
        child: SizedBox(
          height: 1000,
          child: PaginationView(
            key: this.key,
            preloadedItems: [],
            paginationViewType: PaginationViewType.listView,
            itemBuilder: (BuildContext context, item, int index) {
              if (this.type == TypeSearch.collab) {
                return CollabTile(
                  collab: item,
                  isSearchTile: true,
                  ancestorSetState: setState,
                );
              } else if (this.type == TypeSearch.event) {
                return EventTile(
                  event: item,
                  isSearchTile: true,
                  ancestorSetState: setState,
                );
              } else {
                return TileItem(item, type,
                    showType: false, forceSubtitle: false);
              }
            },
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
