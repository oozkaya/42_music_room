import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify/spotify.dart';

import '../lib/services/spotify/api/user.dart';
import 'helpers/firebase_performance_mock.dart';
import 'helpers/spotify_api_mock.dart';

Future main() async {
  setupFirebasePerformanceMocks();
  var spotifyApi = SpotifyApiMock(SpotifyApiCredentials(
    'clientId',
    'clientSecret',
  ));

  group('[SpotifyApi][user]', () {
    setUpAll(() async {
      await Firebase.initializeApp();
    });

    test('getRecentlyPlayed', () async {
      var result = await getRecentlyPlayed(spotifyApi, isMetricEnabled: false);
      expect(result.length, 2);
      var first = result.first;
      expect(first.track != null, true);

      var firstTrack = first.track;
      expect(firstTrack.durationMs, 108546);
      expect(firstTrack.explicit, false);
      expect(firstTrack.id, '2gNfxysfBRfl9Lvi9T3v6R');
      expect(firstTrack.artists.length, 1);
      expect(firstTrack.artists.first.name, 'Tame Impala');

      var second = result.last;
      expect(second.playedAt, DateTime.tryParse('2016-12-13T20:42:17.016Z'));
      expect(second.context.uri, 'spotify:artist:5INjqkS1o8h1imAzPqGZBb');
    });
  });
}
