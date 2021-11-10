import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/spotify/player_state.dart';
import '../../providers/spotify_player_provider.dart';
import '../../app_localizations.dart';
import 'home/home_screen.dart';
import 'library/library_screen.dart';
import 'search/search_screen.dart';
import 'players/miniPlayer/mini_player.dart';

/// This is the stateful widget that the main application instantiates.
class MusicRoomScreen extends StatefulWidget {
  MusicRoomScreen();

  @override
  _MusicRoomScreenState createState() => _MusicRoomScreenState();
}

/// This is the private State class that goes with MusicRoomScreen.
class _MusicRoomScreenState extends State<MusicRoomScreen>
    with WidgetsBindingObserver {
  SpotifyPlayerProvider playerProvider;
  int _selectedIndex = 0;
  final pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    playerProvider = Provider.of<SpotifyPlayerProvider>(context, listen: false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed)
      getPlayerState().then((state) => playerProvider.setPlayerState(state));
    if (state == AppLifecycleState.paused) playerProvider.stopTimer();
  }

  @override
  void dispose() {
    playerProvider.stopTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  static final List _widgetOptions = <Map<String, Object>>[
    {'key': GlobalKey<NavigatorState>(), 'screen': HomeScreen()},
    {'key': GlobalKey<NavigatorState>(), 'screen': SearchScreen()},
    {'key': GlobalKey<NavigatorState>(), 'screen': LibraryScreen()},
  ];

  void _onPageChanged(BuildContext context, int index) {
    Navigator.popUntil(context, (route) => route.isFirst);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(children: [
          Expanded(
            child: Navigator(
              onGenerateRoute: (route) => MaterialPageRoute(
                settings: route,
                builder: (context) => PageView(
                  controller: pageController,
                  onPageChanged: (index) => _onPageChanged(context, index),
                  children: _widgetOptions
                      .map((item) => item['screen'])
                      .cast<Widget>()
                      .toList(),
                ),
              ),
            ),
          ),
          MiniPlayer(),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppLocalizations.of(context).translate("musicHomeTitle"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: AppLocalizations.of(context).translate("musicSearchTitle"),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: AppLocalizations.of(context).translate("musicLibraryTitle"),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).bottomAppBarTheme.color,
        onTap: (index) => pageController.jumpToPage(index),
      ),
    );
  }
}
