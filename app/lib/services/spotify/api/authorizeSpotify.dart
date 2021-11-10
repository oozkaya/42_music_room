import 'dart:async';

import 'package:spotify/spotify.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

Future<SpotifyApi> authorizeSpotify({
  String clientId,
  String clientSecret,
  String redirectUrl,
  List<String> scopes,
}) async {
  final credentials = SpotifyApiCredentials(clientId, clientSecret);
  final grant = SpotifyApi.authorizationCodeGrant(credentials);

  final authUri = grant.getAuthorizationUrl(
    Uri.parse(redirectUrl),
    scopes: scopes,
  );

  await launch(authUri.toString());

  final Completer<SpotifyApi> c = new Completer<SpotifyApi>();
  getLinksStream().listen((String link) async {
    if (link.startsWith(redirectUrl)) {
      SpotifyApi spotifyApi = SpotifyApi.fromAuthCodeGrant(grant, link);
      c.complete(spotifyApi);
    }
  });

  return c.future;
}
