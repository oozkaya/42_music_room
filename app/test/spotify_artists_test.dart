import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify/spotify.dart';

import '../lib/services/spotify/api/artist.dart';
import 'helpers/firebase_performance_mock.dart';
import 'helpers/spotify_api_mock.dart';

Future main() async {
  setupFirebasePerformanceMocks();
  var spotifyApi = SpotifyApiMock(SpotifyApiCredentials(
    'clientId',
    'clientSecret',
  ));

  group('[SpotifyApi][artists]', () {
    setUpAll(() async {
      await Firebase.initializeApp();
    });

    test('getArtist', () async {
      var artist = await getArtist(spotifyApi, '0TnOYISbd1XYRBk9myaseg',
          isMetricEnabled: false);
      expect(artist.type, 'artist');
      expect(artist.id, '0TnOYISbd1XYRBk9myaseg');
      expect(artist.images.length, 3);
    });
  });
}
