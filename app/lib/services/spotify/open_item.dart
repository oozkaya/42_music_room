import 'package:MusicRoom42/services/realtime_database/databases/common.dart';
import 'package:MusicRoom42/services/realtime_database/databases/events.dart'
    as EventsDB;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart';

import '../realtime_database/databases/sessions.dart';
import '../../app_localizations.dart';
import '../../exceptions/cantPlayOnDemandException.dart';
import '../../models/_models.dart';
import '../../providers/spotify_app_provider.dart';
import '../../providers/spotify_player_provider.dart';
import '../../ui/musicroom/subpages/album/album_screen.dart';
import '../../ui/musicroom/subpages/artist/artist_screen.dart';
import '../../ui/musicroom/subpages/playlist/playlist_screen.dart';
import '../../ui/utils/toast/toast_utils.dart';
import './player_basics.dart';
import './spotify_queue.dart';

Future<void> playBySpotifyUri(BuildContext context,
    SpotifyPlayerProvider playerProvider, String spotifyUri,
    {bool isShuffle, bool asRadio = true, bool addHistory = true}) async {
  try {
    if (playerProvider.track?.uri != null && addHistory == true) {
      playerProvider.addHistory(playerProvider.track.uri);
    }
    await takeSessionLead(playerProvider);
    await play(spotifyUri: spotifyUri, asRadio: asRadio);
    playerProvider.setPosition(0);
    if (isShuffle != null) {
      playerProvider.setIsShuffling(isShuffle);
    }
    await playerProvider.fetchPlayerState();
  } on CantPlayOnDemandException {
    ToastUtils.showCustomToast(context,
        AppLocalizations.of(context).translate("spotifyCantPlayOnDemand"),
        level: ToastLevel.Info, durationSec: 10);
  } catch (e) {
    ToastUtils.showCustomToast(context, e.toString(),
        level: ToastLevel.Error, durationSec: 10);
  }
}

Future<void> playAlbumTrack(
    BuildContext context,
    SpotifyPlayerProvider playerProvider,
    Album album,
    TrackSimple track) async {
  if (playerProvider.eventId != null) return;
  await playBySpotifyUri(context, playerProvider, track.uri);
  await queue(album.uri);
}

Future<void> playArtistTrack(
    BuildContext context,
    SpotifyPlayerProvider playerProvider,
    Artist artist,
    TrackSimple track) async {
  if (playerProvider.eventId != null) return;
  await playBySpotifyUri(context, playerProvider, track.uri);
  await queue(artist.uri);
}

Future<void> playPlaylistTrack(
    BuildContext context,
    SpotifyPlayerProvider playerProvider,
    Playlist playlist,
    TrackSimple track) async {
  if (playerProvider.eventId != null) return;
  await playBySpotifyUri(context, playerProvider, track.uri);
  await queue(playlist.uri);
}

void addListToLocalQueue(
  SpotifyPlayerProvider playerProvider,
  List<dynamic> tracksList,
  String trackIdPlayed,
  bool isShuffle,
) {
  List<Track> queueList = [...tracksList];
  var trackIndex = tracksList.indexWhere((t) => t.id == trackIdPlayed);
  if (isShuffle) {
    if (trackIndex >= 0) queueList.removeAt(trackIndex);
    queueList.shuffle();
  } else if (trackIndex >= 0) {
    queueList = queueList.sublist(trackIndex + 1);
  }
  playerProvider.addQueue(tracks: queueList, clearQueue: true);
}

Future<void> playCollabTrack(
    BuildContext context,
    SpotifyPlayerProvider playerProvider,
    Collab collab,
    Track track,
    bool isShuffle) async {
  if (playerProvider.eventId != null) return;
  await playBySpotifyUri(context, playerProvider, track.uri,
      isShuffle: isShuffle);

  addListToLocalQueue(playerProvider, collab.tracks, track.id, isShuffle);
}

Future<void> playEventTrack(
    BuildContext context,
    SpotifyPlayerProvider playerProvider,
    EventModel event,
    Track track,
    bool isShuffle) async {
  await playBySpotifyUri(context, playerProvider, track.uri,
      isShuffle: isShuffle);
  var eventId = playerProvider.eventId;
  var isEventAdmin = playerProvider.isEventAdmin;
  await EventsDB.sendTracks(eventId, event.tracks, isEventAdmin);
  await EventsDB.sendIsPaused(eventId, false, isEventAdmin);
  await EventsDB.sendPosition(eventId, 0, isEventAdmin);

  List<Track> tracksList = event.tracks.map((EventTrack e) => e.track).toList();
  addListToLocalQueue(playerProvider, tracksList, track.id, isShuffle);
}

Future<void> handleOpenAlbum(BuildContext context, String itemId) async {
  SpotifyRemoteAppProvider remoteAppProvider =
      Provider.of<SpotifyRemoteAppProvider>(context, listen: false);
  var spotifyApi = remoteAppProvider.spotifyApi;
  Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AlbumScreen(spotifyApi, itemId)));
}

Future<void> handleOpenArtist(BuildContext context, String itemId) async {
  SpotifyRemoteAppProvider remoteAppProvider =
      Provider.of<SpotifyRemoteAppProvider>(context, listen: false);
  var spotifyApi = remoteAppProvider.spotifyApi;
  Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ArtistScreen(spotifyApi, itemId)));
}

Future<void> handleOpenPlaylist(BuildContext context, String itemId) async {
  SpotifyRemoteAppProvider remoteAppProvider =
      Provider.of<SpotifyRemoteAppProvider>(context, listen: false);
  var spotifyApi = remoteAppProvider.spotifyApi;
  Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PlaylistScreen(spotifyApi, itemId)));
}

Future<void> openItem(
  BuildContext context,
  SpotifyPlayerProvider playerProvider,
  dynamic item,
  String type, {
  dynamic containerItem,
  bool isShuffling,
}) async {
  var isShuffle =
      isShuffling != null ? isShuffling : playerProvider.isShuffling;

  switch (type) {
    case TypeSearch.TRACK_KEY:
      var track = item is Track ? item : Track.fromJson(item);
      await playBySpotifyUri(context, playerProvider, track.uri,
          isShuffle: isShuffle);
      break;
    case TypeSearch.ALBUM_KEY:
      var album = item is Album ? item : Album.fromJson(item);
      handleOpenAlbum(context, album.id);
      break;
    case TypeSearch.ARTIST_KEY:
      var artist = item is Artist ? item : Artist.fromJson(item);
      handleOpenArtist(context, artist.id);
      break;
    case TypeSearch.PLAYLIST_KEY:
      var playlist = item is Playlist ? item : Playlist.fromJson(item);
      handleOpenPlaylist(context, playlist.id);
      break;
    case TypeSearch.COLLAB_KEY:
      playCollabTrack(context, playerProvider, containerItem, item, isShuffle);
      break;
    case TypeSearch.EVENT_KEY:
      playEventTrack(context, playerProvider, containerItem, item, isShuffle);
      break;
  }
}
