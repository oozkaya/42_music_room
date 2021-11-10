import 'package:firebase_performance/firebase_performance.dart';
// import 'package:logger/logger.dart';
import 'package:spotify/spotify.dart';

import '../../../utils/logger.dart';

Future<Album> getAlbum(dynamic spotifyApi, String albumId,
    {bool isMetricEnabled = true}) async {
  Trace myTrace;
  Album res;
  try {
    if (isMetricEnabled) {
      myTrace = FirebasePerformance.instance.newTrace("spotifyApi:getAlbum");
      myTrace.start();
    }

    res = await spotifyApi.albums.get(albumId);

    if (isMetricEnabled) myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    if (isMetricEnabled) myTrace.incrementMetric("error", 1);
  }
  if (isMetricEnabled) myTrace.stop();
  return res;
}

Future<Page<TrackSimple>> getTracks(dynamic spotifyApi, String albumId,
    {int limit = 0, int offset = 0, bool isMetricEnabled = true}) async {
  Trace myTrace;
  Page<TrackSimple> res;
  try {
    if (isMetricEnabled) {
      myTrace = FirebasePerformance.instance.newTrace("spotifyApi:getTracks");
      myTrace.start();
    }

    res = await spotifyApi.albums.getTracks(albumId).getPage(limit, offset);

    if (isMetricEnabled) myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    if (isMetricEnabled) myTrace.incrementMetric("error", 1);
  }
  if (isMetricEnabled) myTrace.stop();
  return res;
}
