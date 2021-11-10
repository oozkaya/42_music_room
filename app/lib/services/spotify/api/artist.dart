import 'package:firebase_performance/firebase_performance.dart';
// import 'package:logger/logger.dart';
import 'package:spotify/spotify.dart';

import '../../../utils/logger.dart';

Future<Artist> getArtist(dynamic spotifyApi, String artistId,
    {bool isMetricEnabled = true}) async {
  Trace myTrace;
  Artist res;
  try {
    if (isMetricEnabled) {
      myTrace = FirebasePerformance.instance.newTrace("spotifyApi:getArtist");
      myTrace.start();
    }

    res = await spotifyApi.artists.get(artistId);

    if (isMetricEnabled) myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
  }
  if (isMetricEnabled) myTrace.stop();
  return res;
}

Future<Page<Album>> getArtistAlbums(
    dynamic spotifyApi, String artistId, List<String> includeGroups,
    {int limit = 20, int offset = 0, bool isMetricEnabled = true}) async {
  Trace myTrace;

  Page<Album> res;
  try {
    if (isMetricEnabled) {
      myTrace =
          FirebasePerformance.instance.newTrace("spotifyApi:getArtistAlbums");
      myTrace.start();
    }

    res = await spotifyApi.artists
        .albums(
          artistId,
          includeGroups: includeGroups,
        )
        .getPage(limit, offset);

    if (isMetricEnabled) myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    if (isMetricEnabled) myTrace.incrementMetric("error", 1);
  }
  if (isMetricEnabled) myTrace.stop();
  return res;
}

Future<Iterable<Artist>> getRelatedArtists(dynamic spotifyApi, String artistId,
    {bool isMetricEnabled = true}) async {
  Trace myTrace;
  Iterable<Artist> res;
  try {
    if (isMetricEnabled) {
      myTrace =
          FirebasePerformance.instance.newTrace("spotifyApi:getRelatedArtists");
      myTrace.start();
    }

    res = await spotifyApi.artists.getRelatedArtists(artistId);

    if (isMetricEnabled) myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    if (isMetricEnabled) myTrace.incrementMetric("error", 1);
  }
  if (isMetricEnabled) myTrace.stop();
  return res;
}

Future<Iterable<Track>> getArtistTopTracks(dynamic spotifyApi, String artistId,
    {bool isMetricEnabled = true}) async {
  Trace myTrace;

  Iterable<Track> res;
  try {
    if (isMetricEnabled) {
      myTrace = FirebasePerformance.instance
          .newTrace("spotifyApi:getArtistTopTracks");
      myTrace.start();
    }

    res = await spotifyApi.artists.getTopTracks(
      artistId,
      'FR',
    ); // TODO: set country code programmatically

    if (isMetricEnabled) myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    if (isMetricEnabled) myTrace.incrementMetric("error", 1);
  }
  if (isMetricEnabled) myTrace.stop();
  return res;
}
