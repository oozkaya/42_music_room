import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify/spotify.dart';

import '../lib/services/spotify/api/search.dart';
import 'helpers/firebase_performance_mock.dart';
import 'helpers/spotify_api_mock.dart';

Future main() async {
  setupFirebasePerformanceMocks();
  var spotifyApi = SpotifyApiMock(SpotifyApiCredentials(
    'clientId',
    'clientSecret',
  ));

  group('[SpotifyApi][search]', () {
    setUpAll(() async {
      await Firebase.initializeApp();
    });

    test('search', () async {
      var searchResult =
          await search(spotifyApi, q: 'metallica', isMetricEnabled: false);
      expect(searchResult.length, 2);
    });
  });
}
