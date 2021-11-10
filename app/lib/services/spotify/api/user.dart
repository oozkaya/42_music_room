import 'package:firebase_performance/firebase_performance.dart';
// import 'package:logger/logger.dart';
import 'package:spotify/spotify.dart';

import '../../../utils/logger.dart';

Future<User> getUser(dynamic spotifyApi, {bool isMetricEnabled = true}) async {
  Trace myTrace;
  User user;
  try {
    if (isMetricEnabled) {
      myTrace = FirebasePerformance.instance.newTrace("spotifyApi:getUser");
      myTrace.start();
    }

    user = await spotifyApi.me.get();

    if (isMetricEnabled) myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.toString());
    if (isMetricEnabled) myTrace.incrementMetric("error", 1);
  }
  if (isMetricEnabled) myTrace.stop();
  return user;
}

Future<Iterable<PlayHistory>> getRecentlyPlayed(dynamic spotifyApi,
    {bool isMetricEnabled = true}) async {
  Trace myTrace;
  Iterable<PlayHistory> res;
  try {
    if (isMetricEnabled) {
      myTrace =
          FirebasePerformance.instance.newTrace("spotifyApi:getRecentlyPlayed");
      myTrace.start();
    }

    res = await spotifyApi.me.recentlyPlayed();

    if (isMetricEnabled) myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    if (isMetricEnabled) myTrace.incrementMetric("error", 1);
  }
  if (isMetricEnabled) myTrace.stop();
  return res;
}

Future<Iterable<Artist>> getTopArtists(dynamic spotifyApi,
    {bool isMetricEnabled = true}) async {
  Trace myTrace;
  Iterable<Artist> res;
  try {
    if (isMetricEnabled) {
      myTrace =
          FirebasePerformance.instance.newTrace("spotifyApi:getTopArtists");
      myTrace.start();
    }

    res = await spotifyApi.me.topArtists();

    if (isMetricEnabled) myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    if (isMetricEnabled) myTrace.incrementMetric("error", 1);
  }
  if (isMetricEnabled) myTrace.stop();
  return res;
}

Future<Iterable<Track>> getTopTracks(dynamic spotifyApi,
    {bool isMetricEnabled = true}) async {
  Trace myTrace;
  Iterable<Track> res;
  try {
    if (isMetricEnabled) {
      myTrace =
          FirebasePerformance.instance.newTrace("spotifyApi:getTopTracks");
      myTrace.start();
    }

    res = await spotifyApi.me.topTracks();

    if (isMetricEnabled) myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    if (isMetricEnabled) myTrace.incrementMetric("error", 1);
  }
  if (isMetricEnabled) myTrace.stop();
  return res;
}

Future<Iterable<TrackSaved>> getLikedSongs(dynamic spotifyApi,
    {bool isMetricEnabled = true}) async {
  Trace myTrace;
  Iterable<TrackSaved> res;
  try {
    if (isMetricEnabled) {
      myTrace =
          FirebasePerformance.instance.newTrace("spotifyApi:getLikedSongs");
      myTrace.start();
    }

    res = await spotifyApi.tracks.me.saved.all();

    if (isMetricEnabled) myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    if (isMetricEnabled) myTrace.incrementMetric("error", 1);
  }
  if (isMetricEnabled) myTrace.stop();
  return res;
}
