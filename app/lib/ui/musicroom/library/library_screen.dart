import 'package:MusicRoom42/app_localizations.dart';
import 'package:MusicRoom42/ui/musicroom/library/session/session_tabs.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';

import './events/user_events.dart';
import './playlists/playlists_tabs.dart';

class LibraryScreen extends StatefulWidget {
  final bool addTrackScreen;
  final Track track;
  final Function onAdd;

  LibraryScreen({this.addTrackScreen, this.track, this.onAdd});

  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var tabs = [
      PlaylistsTabs(
        addTrackScreen: widget.addTrackScreen,
        track: widget.track,
        onAdd: widget.onAdd,
      ),
      UserEvents(
        addTrackScreen: widget.addTrackScreen,
        track: widget.track,
        onAdd: widget.onAdd,
      ),
      SessionTabs(),
    ];

    return DefaultTabController(
      initialIndex: 0,
      length: tabs.length,
      child: SafeArea(
        child: Scaffold(
          appBar: widget.addTrackScreen == true
              ? AppBar(
                  title: Text(AppLocalizations.of(context).translate('addTo')),
                )
              : null,
          body: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                          text: AppLocalizations.of(context)
                              .translate('playlists')),
                      Tab(
                          text:
                              AppLocalizations.of(context).translate('events')),
                      Tab(
                          text: AppLocalizations.of(context)
                              .translate('session')),
                    ],
                    labelColor: Theme.of(context).colorScheme.onPrimary,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: Theme.of(context).textTheme.headline5.fontSize,
                    ),
                    unselectedLabelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: Theme.of(context).textTheme.headline5.fontSize,
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
