import 'package:MusicRoom42/utils/spotify/uriToId.dart';
import 'package:firebase_performance/firebase_performance.dart';
// import 'package:logger/logger.dart';
import 'package:spotify/spotify.dart';

import '../../../utils/logger.dart';

Future<Track> getTrack(SpotifyApi spotifyApi, String trackId,
    {String trackUri}) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("spotifyApi:getTrack");
  Track res;
  String id = trackId;
  try {
    myTrace.start();

    if (trackUri != null) id = uriToId(trackUri);
    res = await spotifyApi.tracks.get(id);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.toString() + ' (trackId: $trackId)');
    myTrace.incrementMetric("error", 1);
  }
  myTrace.stop();
  return res;
}

Future<String> getTrackImage(SpotifyApi spotifyApi, String trackId) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("spotifyApi:getTrackImage");
  String res;
  try {
    myTrace.start();

    Track track = await spotifyApi.tracks.get(trackId);
    res = track.album.images.first.url;

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    myTrace.incrementMetric("error", 1);
  }
  myTrace.stop();
  return res;
}

Future<Null> saveTrack(SpotifyApi spotifyApi, String trackId) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("spotifyApi:saveTrack");
  try {
    myTrace.start();

    await spotifyApi.tracks.me.saveOne(trackId);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    myTrace.incrementMetric("error", 1);
  }
  myTrace.stop();
}

Future<Null> unsaveTrack(SpotifyApi spotifyApi, String trackId) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("spotifyApi:unsaveTrack");
  try {
    myTrace.start();

    await spotifyApi.tracks.me.deleteOne(trackId);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
  }
  myTrace.stop();
}

Future<bool> isTrackSaved(SpotifyApi spotifyApi, String trackId) async {
  final Trace myTrace =
      FirebasePerformance.instance.newTrace("spotifyApi:isTrackSaved");
  if (trackId == null) return false;
  bool res;
  try {
    myTrace.start();

    res = await spotifyApi.tracks.me.containsOne(trackId);

    myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err);
    myTrace.incrementMetric("error", 1);
    res = false;
  }
  myTrace.stop();
  return res;
}
