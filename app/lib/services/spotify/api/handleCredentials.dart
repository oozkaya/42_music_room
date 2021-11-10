import 'dart:async';

import 'package:MusicRoom42/services/spotify/spotify_app_remote.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:logger/logger.dart';
import 'package:spotify/spotify.dart';

import '../../../caches/sharedpref/shared_preference_helper.dart';
import '../../../providers/spotify_app_provider.dart';
import '../../../services/spotify/api/authorizeSpotify.dart';
import '../../../services/spotify/api/user.dart';

import '../../../utils/logger.dart';

Future<void> handleCredentials(SpotifyRemoteAppProvider provider) async {
  SharedPreferenceHelper sharedPrefs = SharedPreferenceHelper();
  SpotifyApiCredentials savedCredentials = await sharedPrefs.getCredentials();
  SpotifyApi spotifyApi;

  if (savedCredentials == null) {
    spotifyApi = await authorizeSpotify(
      clientId: env['SPOTIFY_CLIENT_ID'].toString(),
      clientSecret: env['SPOTIFY_CLIENT_SECRET'].toString(),
      redirectUrl: env['SPOTIFY_REDIRECT_URL'].toString(),
      scopes: provider.scopes,
    );
    SpotifyApiCredentials cred = await spotifyApi.getCredentials();
    spotifyApi = SpotifyApi(cred,
        onCredentialsRefreshed: (SpotifyApiCredentials newCred) async {
      await sharedPrefs.setCredentials(newCred);
      CustomLogger().i('Saved from oauth : ' + newCred.refreshToken);
    });
  } else {
    SpotifyApiCredentials credentials = SpotifyApiCredentials(
      savedCredentials.clientId,
      savedCredentials.clientSecret,
      accessToken: savedCredentials.accessToken,
      refreshToken: savedCredentials.refreshToken,
      scopes: savedCredentials.scopes,
      expiration: savedCredentials.expiration,
    );
    spotifyApi = SpotifyApi(credentials,
        onCredentialsRefreshed: (SpotifyApiCredentials newCred) async {
      await sharedPrefs.setCredentials(newCred);
      CustomLogger().i('Saved from oauth : ' + newCred.refreshToken);
    });
  }

  User user = await getUser(spotifyApi);
  provider.setUserId(user.id);
  provider.setUsername(user.displayName);
  provider.setSpotifyApi(spotifyApi);

  SpotifyApiCredentials updatedCredentials = await spotifyApi.getCredentials();
  await sharedPrefs.setCredentials(updatedCredentials);

  await connectToSpotifyRemote(provider);
}
