import 'package:flutter/services.dart';
// import 'package:logger/logger.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

import './set_status.dart';

import '../../utils/logger.dart';

var _logger = CustomLogger();

Future<void> setShuffle({bool shuffle}) async {
  try {
    await SpotifySdk.setShuffle(
      shuffle: shuffle,
    );
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message, logger: _logger);
  } on MissingPluginException {
    setStatus('not implemented', logger: _logger);
  }
}

Future<void> toggleShuffle() async {
  try {
    await SpotifySdk.toggleShuffle();
  } on PlatformException catch (e) {
    setStatus(e.code, message: e.message, logger: _logger);
  } on MissingPluginException {
    setStatus('not implemented', logger: _logger);
  }
}
