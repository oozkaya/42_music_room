import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';

import '../../../../app_localizations.dart';
import './collabs/collabs_playlists.dart';
import './official/official_playlists.dart';

class PlaylistsTabs extends StatefulWidget {
  final bool addTrackScreen;
  final Track track;
  final Function onAdd;

  PlaylistsTabs({this.addTrackScreen, this.track, this.onAdd});

  @override
  _PlaylistsTabsState createState() => _PlaylistsTabsState();
}

class _PlaylistsTabsState extends State<PlaylistsTabs>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  var tabs = [
    CollabsPlaylists(),
    OfficialPlaylists(),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: tabs.length, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.addTrackScreen == true
        ? CollabsPlaylists(
            addTrackScreen: widget.addTrackScreen,
            track: widget.track,
            onAdd: widget.onAdd,
          )
        : DefaultTabController(
            initialIndex: 0,
            length: tabs.length,
            child: SafeArea(
              child: Scaffold(
                body: Column(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: TabBar(
                            controller: _tabController,
                            tabs: [
                              Tab(
                                text: AppLocalizations.of(context)
                                    .translate('collabs'),
                              ),
                              Tab(
                                text: AppLocalizations.of(context)
                                    .translate('officials'),
                              ),
                            ],
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onPrimary,
                            ),
                            labelColor:
                                Theme.of(context).colorScheme.onSecondary,
                            unselectedLabelColor:
                                Theme.of(context).colorScheme.onSecondary,
                            labelStyle: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .fontSize,
                            ),
                            unselectedLabelStyle: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .fontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: tabs,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
