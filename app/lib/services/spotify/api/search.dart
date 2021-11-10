import 'package:MusicRoom42/models/_models.dart';
import 'package:firebase_performance/firebase_performance.dart';
// import 'package:logger/logger.dart';
import 'package:spotify/spotify.dart';

import '../../../utils/logger.dart';

Future<List<Page<Object>>> search(dynamic spotifyApi,
    {String q,
    num limit = 10,
    num offset = 0,
    Iterable<SearchType> types = TypeSearch.allSpotify,
    bool isMetricEnabled = true}) async {
  Trace myTrace;
  List<Page<Object>> res;
  try {
    if (isMetricEnabled) {
      myTrace = FirebasePerformance.instance.newTrace("spotifyApi:search");
      myTrace.start();
    }

    res = await spotifyApi.search.get(q, types: types).getPage(limit, offset);

    if (isMetricEnabled) myTrace.incrementMetric("success", 1);
  } catch (err) {
    CustomLogger().e(err.message);
    if (isMetricEnabled) myTrace.incrementMetric("error", 1);
  }
  if (isMetricEnabled) myTrace.stop();
  return res;
}
