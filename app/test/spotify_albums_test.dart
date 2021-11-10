import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotify/spotify.dart';

import '../lib/services/spotify/api/album.dart';
import 'helpers/firebase_performance_mock.dart';
import 'helpers/spotify_api_mock.dart';

Future main() async {
  setupFirebasePerformanceMocks();
  var spotifyApi = SpotifyApiMock(SpotifyApiCredentials(
    'clientId',
    'clientSecret',
  ));

  group('[SpotifyApi][albums]', () {
    setUpAll(() async {
      await Firebase.initializeApp();
    });
    test('getAlbum', () async {
      var album = await getAlbum(spotifyApi, '4aawyAB9vmqN3uQ7FjRGTy',
          isMetricEnabled: false);
      inspect(album);

      expect(album.albumType, 'album');
      expect(album.id, '4aawyAB9vmqN3uQ7FjRGTy');
      expect(album.images.length, 3);
      expect(album.releaseDatePrecision, DatePrecision.day);
      expect(album.releaseDate, '2012-11-13');
    });

    test('getTracks', () async {
      var album = await getTracks(spotifyApi, '4aawyAB9vmqN3uQ7FjRGTy',
          isMetricEnabled: false);
      var items = album.items;

      expect(items.length, 3);

      var trackOne = items.first;
      expect(trackOne.discNumber, 1);
      expect(trackOne.durationMs, 85400);
      expect(trackOne.id, '6OmhkSOpvYBokMKQxpIGx2');
      expect(trackOne.isPlayable, true);
      expect(trackOne.type, 'track');
      expect(trackOne.uri, 'spotify:track:6OmhkSOpvYBokMKQxpIGx2');
      expect(trackOne.explicit, true);
      expect(trackOne.href,
          'https://api.spotify.com/v1/tracks/6OmhkSOpvYBokMKQxpIGx2');
      expect(trackOne.previewUrl,
          'https://p.scdn.co/mp3-preview/bf9e33b1bb53c281c5eea0da6c317f2cd7c3eb58?cid=8897482848704f2a8f8d7c79726a70d4');
      expect(trackOne.name, 'Global Warming');

      expect(trackOne.externalUrls != null, true);
      expect(trackOne.externalUrls.spotify,
          'https://open.spotify.com/track/6OmhkSOpvYBokMKQxpIGx2');

      var artists = trackOne.artists;
      expect(artists.length, 2);
      expect(artists[0].name, 'Pitbull');
      expect(artists[1].name, 'Sensato');
    });
  });
}
