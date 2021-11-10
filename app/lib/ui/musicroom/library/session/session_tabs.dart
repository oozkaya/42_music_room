import 'package:MusicRoom42/services/realtime_database/databases/sessions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../../../providers/spotify_player_provider.dart';
import '../../../../ui/musicroom/library/session/session_create.dart';
import '../../../../ui/musicroom/library/session/session_members.dart';

class SessionTabs extends StatefulWidget {
  @override
  SessionTabsState createState() => SessionTabsState();
}

class SessionTabsState extends State<SessionTabs> {
  Future<bool> _asyncInit() async {
    var playerProvider =
        Provider.of<SpotifyPlayerProvider>(context, listen: false);
    String sessionId = playerProvider.sessionId;
    String trackUri = playerProvider.track.uri;
    int playbackPosition = playerProvider.playbackPosition;
    bool isPaused = playerProvider.isPaused;

    if (playerProvider.isSessionMaster)
      Future.wait([
        sendTrackUri(sessionId, trackUri),
        sendPosition(sessionId, playbackPosition),
        sendIsPaused(sessionId, isPaused),
      ]);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _asyncInit(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          return Selector<SpotifyPlayerProvider, Tuple2<String, List<String>>>(
            selector: (_, model) =>
                Tuple2(model?.sessionId, model?.sessionMembers),
            builder: (_, data, __) {
              // sessionId is also equal to the adminId
              String sessionId = data.item1;
              List<String> members = data.item2;

              if (sessionId == null) return CreateSession();
              return SessionMembers(members, sessionId);
            },
          );
        });
  }
}
