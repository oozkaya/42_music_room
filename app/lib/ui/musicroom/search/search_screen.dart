import 'package:MusicRoom42/services/firestore/collections/events_collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';

import '../../../models/_models.dart';
import '../../../providers/spotify_app_provider.dart';
import '../../../services/firestore/collections/collabs_collection.dart';
import '../../../services/spotify/api/search.dart';
import './searchbar/search_bar.dart';
import './results/search_results.dart';

class SearchState {
  String _searchQuery;
  List<Page<Object>> _spotifyResults;
  ReadableCollabsResults _collabResults;
  ReadableEventsResults _eventResults;

  ReadableCollabsResults get collabResults => _collabResults;
  ReadableEventsResults get eventResults => _eventResults;
  String get searchQuery => _searchQuery;
  List<Page<Object>> get spotifyResults => _spotifyResults;

  getSpotifyResultsByType(TypeSearch type) {
    if (_spotifyResults == null) return;

    for (var pages in _spotifyResults) {
      var firstItem = pages?.metadata?.itemsNative
          ?.firstWhere((item) => item != null, orElse: () => null);
      var firstItemType = firstItem != null ? firstItem['type'] : null;
      if (firstItemType == type.key) return pages.metadata.itemsNative;
    }
  }

  void setQuery(String query) => _searchQuery = query;
  void setSpotifyResults(List<Page<Object>> results) =>
      _spotifyResults = results;
  void setCollabResults(ReadableCollabsResults results) {
    _collabResults = results;
  }

  void setEventsResults(ReadableEventsResults results) =>
      _eventResults = results;
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchState searchState = SearchState();

  @override
  Widget build(BuildContext context) {
    SpotifyRemoteAppProvider remoteAppProvider = Provider.of(context);

    Future<void> onSubmitted(query) async {
      if (query.length > 0) {
        var userId = FirebaseAuth.instance.currentUser.uid;
        await Future.wait([
          search(remoteAppProvider.spotifyApi, q: query, limit: 3, offset: 0)
              .then((res) => searchState.setSpotifyResults(res)),
          CollabsCollection()
              .searchReadableByUserId(userId, query,
                  lastResults: null, limit: 3)
              .then((res) => searchState.setCollabResults(res)),
          EventsCollection()
              .searchReadableByUserId(userId, query,
                  lastResults: null, limit: 3)
              .then((res) => searchState.setEventsResults(res)),
        ]);
        searchState.setQuery(query);
        setState(() {});
      }
    }

    final List<Widget> widgetsList = [
      SearchBar(
        searchQuery: searchState.searchQuery,
        onSubmitted: onSubmitted,
      ),
      SearchResults(searchState),
    ];

    return SafeArea(
      child: Column(
        children: widgetsList,
      ),
    );
  }
}
