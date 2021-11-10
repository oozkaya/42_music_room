import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:spotify_sdk/spotify_sdk.dart';

import '../../providers/spotify_app_provider.dart';

import './set_status.dart';

Future<void> connectToSpotifyRemote(
  SpotifyRemoteAppProvider remoteAppProvider,
) async {
  try {
    remoteAppProvider.setIsLoading(true);
    var result = await SpotifySdk.connectToSpotifyRemote(
        clientId: env['SPOTIFY_CLIENT_ID'].toString(),
        redirectUrl: env['SPOTIFY_REDIRECT_URL'].toString());
    setStatus(
        result ? 'connect to spotify successful' : 'connect to spotify failed');
    remoteAppProvider.setIsLoading(false);
    remoteAppProvider.setAppErrorCode(null);
  } on PlatformException catch (e) {
    remoteAppProvider.setIsLoading(false);
    remoteAppProvider.setAppErrorCode(e.code);
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    remoteAppProvider.setIsLoading(false);
    setStatus('not implemented');
  }
}

Future<void> disconnect(
  SpotifyRemoteAppProvider remoteAppProvider,
) async {
  try {
    remoteAppProvider.setIsLoading(false);
    var result = await SpotifySdk.disconnect();
    setStatus(result ? 'disconnect successful' : 'disconnect failed');
    remoteAppProvider.setIsLoading(false);
  } on PlatformException catch (e) {
    remoteAppProvider.setIsLoading(false);
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    remoteAppProvider.setIsLoading(false);
    setStatus('not implemented');
  }
}
