import 'package:MusicRoom42/services/spotify/spotify_app_remote.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:spotify/spotify.dart';
import 'package:spotify_sdk/models/crossfade_state.dart';

import '../services/spotify/api/handleCredentials.dart';

class SpotifyRemoteAppProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isConnected = false;
  List<String> _scopes = [
    'app-remote-control',
    'user-modify-playback-state',
    'user-top-read',
    'user-library-read',
    'user-library-modify',
    'user-read-private',
    'user-read-currently-playing',
    'user-read-recently-played',
    'playlist-read-private',
    'playlist-modify-public',
    'playlist-modify-private',
    "playlist-read-collaborative",
  ];
  SpotifyApi _spotifyApi;
  String _userId;
  String _username;
  String _appErrorCode;
  CrossfadeState _crossfadeState;

  SpotifyRemoteAppProvider() {
    handleCredentials(this);
  }

  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  List<String> get scopes => _scopes;
  String get appErrorCode => _appErrorCode;
  CrossfadeState get crossfadeState => _crossfadeState;
  SpotifyApi get spotifyApi => _spotifyApi;
  String get userId => _userId;
  String get username => _username;

  bool getStreamConnectionStatus(AsyncSnapshot snapshot) {
    if (snapshot.data != null) {
      _isConnected = snapshot.data.connected;
      if (!_isConnected) connectToSpotifyRemote(this);
    }
    return _isConnected;
  }

  void setIsLoading(bool isLoading) {
    _isLoading = isLoading;
  }

  void setAppErrorCode(String errorCode) {
    _appErrorCode = errorCode;
    notifyListeners();
  }

  void setCrossfadeState(CrossfadeState crossfadeState) {
    _crossfadeState = crossfadeState;
  }

  void setSpotifyApi(SpotifyApi spotifyApi) {
    _spotifyApi = spotifyApi;
    notifyListeners();
  }

  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }
}
