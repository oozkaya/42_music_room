import 'package:flutter/services.dart';
// import 'package:logger/logger.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import './set_status.dart';

import '../../utils/logger.dart';

var _logger = CustomLogger();

Future<void> toggleRepeat() async {
  try {
    await SpotifySdk.toggleRepeat();
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message, logger: _logger);
  } on MissingPluginException {
    setStatus('not implemented', logger: _logger);
  }
}

Future<void> setRepeatMode(RepeatMode repeatMode) async {
  try {
    await SpotifySdk.setRepeatMode(
      repeatMode: repeatMode,
    );
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message);
  } on MissingPluginException {
    setStatus('not implemented');
  }
}
