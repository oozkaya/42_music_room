import 'package:MusicRoom42/providers/spotify_app_provider.dart';
import 'package:MusicRoom42/providers/spotify_player_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/_models.dart';
import '../../services/realtime_database/databases/users.dart';
import '../auth/user_infos_screen.dart';
import '../musicroom/music_room_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool shouldInitProfile = false;
  UserModel user;

  Future<bool> _asyncInit() async {
    final playerProvider =
        Provider.of<SpotifyPlayerProvider>(context, listen: false);
    var remoteAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);
    await playerProvider.init(remoteAppProvider);

    var currentUser = FirebaseAuth.instance.currentUser;
    user = await getUser(currentUser.uid);

    shouldInitProfile = user == null ||
        user.nickName == null ||
        user.favoriteMusicCategory == null;
    return shouldInitProfile;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _asyncInit(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (shouldInitProfile == true) {
              var currentUser = FirebaseAuth.instance.currentUser;
              return UserInfosScreen(currentUser.uid);
            }

            // return ChangeNotifierProvider<SpotifyPlayerProvider>(
            //   create: (ctx) => SpotifyPlayerProvider(ctx),
            //   child: MusicRoomScreen(),
            // );
            return MusicRoomScreen();
          }
        });
  }
}
