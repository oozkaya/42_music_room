import 'package:MusicRoom42/providers/spotify_player_provider.dart';

import './events.dart' as Events;
import './sessions.dart' as Sessions;

Future<void> sendPosition(SpotifyPlayerProvider provider, int position) async {
  await Events.sendPosition(provider.eventId, position, provider.isEventAdmin);
  await Sessions.sendPosition(provider.sessionId, position);
}

Future<void> sendIsPaused(SpotifyPlayerProvider provider, bool isPaused) async {
  await Events.sendIsPaused(provider.eventId, isPaused, provider.isEventAdmin);
  await Sessions.sendIsPaused(provider.sessionId, isPaused);
}
