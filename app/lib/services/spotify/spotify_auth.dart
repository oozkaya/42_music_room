import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import '../../providers/spotify_app_provider.dart';
import './set_status.dart';

Future<String> getAuthenticationToken(
  SpotifyRemoteAppProvider remoteAppProvider,
) async {
  try {
    List<String> scopes = remoteAppProvider.scopes;
    String authenticationToken = await SpotifySdk.getAuthenticationToken(
      clientId: env['SPOTIFY_CLIENT_ID'].toString(),
      redirectUrl: env['SPOTIFY_REDIRECT_URL'].toString(),
      scope: scopes.join(', '),
    );

    setStatus('Got a token: $authenticationToken');
    // remoteAppProvider.setAuthToken(authenticationToken);
    return authenticationToken;
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
    // remoteAppProvider.setAuthToken(null);
    return Future.error('$e.code: $e.message');
  } on MissingPluginException {
    setStatus('not implemented');
    return Future.error('not implemented');
  }
}
