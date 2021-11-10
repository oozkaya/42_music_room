import 'package:flutter/services.dart';

import 'package:spotify_sdk/spotify_sdk.dart';

import '../../exceptions/cantPlayOnDemandException.dart';
import './set_status.dart';

Future<void> play({String spotifyUri, bool asRadio = false}) async {
  try {
    await SpotifySdk.play(spotifyUri: spotifyUri, asRadio: asRadio);
  } on PlatformException catch (e) {
    if (e.details.contains("CANT_PLAY_ON_DEMAND")) {
      throw new CantPlayOnDemandException("Can not play on demand");
    }
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}

Future<void> pause() async {
  try {
    await SpotifySdk.pause();
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}

Future<void> resume() async {
  try {
    await SpotifySdk.resume();
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}

Future<void> skipNext() async {
  try {
    await SpotifySdk.skipNext();
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}

Future<void> skipPrevious() async {
  try {
    await SpotifySdk.skipPrevious();
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}

Future<void> seekTo(int pos) async {
  try {
    await SpotifySdk.seekTo(positionedMilliseconds: pos);
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}

Future<void> seekToRelative() async {
  try {
    await SpotifySdk.seekToRelativePosition(relativeMilliseconds: 20000);
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}
