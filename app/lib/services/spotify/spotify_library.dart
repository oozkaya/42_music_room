import 'package:flutter/services.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import 'set_status.dart';

Future<void> addToLibrary() async {
  try {
    await SpotifySdk.addToLibrary(
      spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m',
    );
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}
