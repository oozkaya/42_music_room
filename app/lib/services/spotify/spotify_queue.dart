import 'package:flutter/services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import 'set_status.dart';

Future<void> queue(String spotifyUri) async {
  try {
    await SpotifySdk.queue(
      spotifyUri: spotifyUri,
    );
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}
