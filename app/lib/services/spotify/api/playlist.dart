import 'package:firebase_performance/firebase_performance.dart';
// import 'package:logger/logger.dart';
import 'package:spotify/spotify.dart';

import '../../../utils/logger.dart';

Future<Playlist> getPlaylistById(
    SpotifyApi spotifyApi, String playlistId) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("spotifyApi:getPlaylistById");
  Playlist res;
  try {
    myTrace.start();

    res = await spotifyApi.playlists.get(playlistId);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    myTrace.incrementMetric("error", 1);
  }
  myTrace.stop();
  return res;
}

Future<Page<Track>> getPlaylistTracksById(
    SpotifyApi spotifyApi, String playlistId,
    {num limit = 100, num offset = 0}) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("spotifyApi:getPlaylistTracksById");
  Page<Track> res;
  try {
    myTrace.start();

    res = await spotifyApi.playlists
        .getTracksByPlaylistId(playlistId)
        .getPage(limit, offset);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    myTrace.incrementMetric("error", 1);
  }
  myTrace.stop();
  return res;
}

Future<Iterable<PlaylistSimple>> getUserPlaylists(SpotifyApi spotifyApi) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("spotifyApi:getUserPlaylists");
  Iterable<PlaylistSimple> playlists;
  try {
    myTrace.start();

    playlists = await spotifyApi.playlists.me.all();

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    myTrace.incrementMetric("error", 1);
  }
  myTrace.stop();
  return playlists;
}

Future<Playlist> createPlaylist(
  SpotifyApi spotifyApi,
  String userId,
  String playlistName,
) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("spotifyApi:createPlaylist");
  Playlist playlist;
  try {
    myTrace.start();

    playlist = await spotifyApi.playlists.createPlaylist(userId, playlistName);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    myTrace.incrementMetric("error", 1);
  }
  myTrace.stop();
  return playlist;
}

Future<void> unfollowPlaylist(
  SpotifyApi spotifyApi,
  String playlistId,
) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("spotifyApi:unfollowPlaylist");
  try {
    myTrace.start();

    await spotifyApi.playlists.unfollowPlaylist(playlistId);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    myTrace.incrementMetric("error", 1);
  }
  myTrace.stop();
}
