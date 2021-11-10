import 'package:flutter/services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import '../../providers/spotify_app_provider.dart';

import 'set_status.dart';

Future getCrossfadeState(
  SpotifyRemoteAppProvider remoteAppProvider,
) async {
  try {
    var crossfadeStateValue = await SpotifySdk.getCrossFadeState();
    remoteAppProvider.setCrossfadeState(crossfadeStateValue);
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}
