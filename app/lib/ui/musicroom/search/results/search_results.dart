import 'package:MusicRoom42/ui/musicroom/widgets/collab_tile.dart';
import 'package:MusicRoom42/ui/musicroom/widgets/event_tile.dart';
import 'package:flutter/material.dart';

import '../../../../app_localizations.dart';
import '../../../../models/_models.dart';
import '../search_screen.dart';
import './search_view_all.dart';
import './tile_item.dart';

enum CustomType { event, collab }

class SearchResults extends StatefulWidget {
  final SearchState searchState;

  SearchResults(this.searchState);

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  @override
  Widget build(BuildContext context) {
    bool noResults = widget.searchState.spotifyResults == null;

    Widget moreResultsByType(TypeSearch type) {
      String translateKey;
      switch (type) {
        case TypeSearch.album:
          translateKey = 'searchViewAllAlbums';
          break;
        case TypeSearch.artist:
          translateKey = 'searchViewAllArtists';
          break;
        case TypeSearch.playlist:
          translateKey = 'searchViewAllPlaylists';
          break;
        case TypeSearch.track:
          translateKey = 'searchViewAllTracks';
          break;
        case TypeSearch.collab:
          translateKey = 'searchViewAllCollabs';
          break;
        case TypeSearch.event:
          translateKey = 'searchViewAllEvents';
          break;
      }

      return InkWell(
        child: Padding(
          padding: EdgeInsets.fromLTRB(70, 0, 20, 5),
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).translate(translateKey),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
                  color: Theme.of(context).colorScheme.secondary,
                  fontStyle: FontStyle.italic),
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SearchViewAllScreen(
                      widget.searchState.searchQuery, type)));
        },
      );
    }

    List<dynamic> resultsByType(TypeSearch type) {
      dynamic items;
      if (type == TypeSearch.collab) {
        items = widget.searchState.collabResults.docs;
      } else if (type == TypeSearch.event) {
        items = widget.searchState.eventResults.docs;
      } else {
        items = widget.searchState.getSpotifyResultsByType(type);
      }
      var results = items?.map((item) {
            if (type == TypeSearch.collab) {
              return CollabTile(
                collab: item,
                isSearchTile: true,
                ancestorSetState: setState,
              );
            } else if (type == TypeSearch.event) {
              return EventTile(
                event: item,
                isSearchTile: true,
                ancestorSetState: setState,
              );
            } else {
              return TileItem(item, type, showType: true, forceSubtitle: true);
            }
          })?.toList() ??
          [];
      if (results.isEmpty) return results;
      results.add(moreResultsByType(type));
      return results;
    }

    return Expanded(
      child: noResults
          ? Center(
              child: Text(
                AppLocalizations.of(context).translate('musicSearchEmpty'),
              ),
            )
          : ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                ...resultsByType(TypeSearch.artist),
                ...resultsByType(TypeSearch.album),
                ...resultsByType(TypeSearch.track),
                ...resultsByType(TypeSearch.playlist),
                ...resultsByType(TypeSearch.collab),
                ...resultsByType(TypeSearch.event),
              ],
            ),
    );
  }
}
