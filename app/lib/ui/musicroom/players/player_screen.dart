import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../../services/spotify/player_state.dart';
import '../../../services/spotify/spotify_app_remote.dart';
import '../../../providers/spotify_app_provider.dart';
import '../../../providers/spotify_player_provider.dart';
import './player_header_widget.dart';
import './player_image_widget.dart';
import './player_infos_widget.dart';
import './player_slider_widget.dart';
import './player_icons_widget.dart';

class PlayerScreen extends StatefulWidget {
  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  SpotifyRemoteAppProvider remoteAppProvider;
  SpotifyPlayerProvider playerProvider;

  @override
  void initState() {
    super.initState();
    playerProvider = Provider.of<SpotifyPlayerProvider>(context, listen: false);
    remoteAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);
    getPlayerState().then((playerState) async {
      if (playerState == null) {
        await connectToSpotifyRemote(remoteAppProvider);
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return Scaffold(
      body: Selector<SpotifyPlayerProvider, Tuple3<Color, String, String>>(
        selector: (_, model) => Tuple3(model?.backgroundColor,
            model?.contextTitle, model?.contextSubtitle),
        builder: (_, data, __) {
          Color color = data.item1;
          String contextTitle = data.item2;
          String contextSubtitle = data.item3;

          return Container(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 40,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  color != null ? color : Colors.brown,
                  Colors.black87,
                ],
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  PlayerHeaderWidget(contextTitle, contextSubtitle, spotifyApi: remoteAppProvider.spotifyApi),
                  SizedBox(height: 70),
                  PlayerImageWidget(),
                  SizedBox(height: 70),
                  PlayerInfosWidget(),
                  PlayerSliderWidget(),
                  PlayerIconsWidget(),
                  // Container(
                  //   padding: EdgeInsets.only(left: 22, right: 22),
                  //   width: double.infinity,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       Icon(
                  //         LineIcons.desktop,
                  //         color: Colors.grey.shade400,
                  //       ),
                  //       Icon(
                  //         LineIcons.alternateListAlt,
                  //         color: Colors.grey.shade400,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
    // );
  }
}
