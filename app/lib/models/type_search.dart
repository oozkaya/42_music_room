part of musicroom.models;

class TypeSearch {
  static const ALBUM_KEY = 'album';
  static const ARTIST_KEY = 'artist';
  static const PLAYLIST_KEY = 'playlist';
  static const TRACK_KEY = 'track';
  static const SHOW_KEY = 'show';
  static const EPISODE_KEY = 'episode';
  static const COLLAB_KEY = 'collab';
  static const EVENT_KEY = 'event';

  final String _key;

  const TypeSearch(this._key);
  String get key => _key;

  static const album = TypeSearch(ALBUM_KEY);
  static const artist = TypeSearch(ARTIST_KEY);
  static const playlist = TypeSearch(PLAYLIST_KEY);
  static const track = TypeSearch(TRACK_KEY);
  static const show = TypeSearch(SHOW_KEY);
  static const episode = TypeSearch(EPISODE_KEY);
  static const allSpotify = SearchType.all;

  static const collab = TypeSearch(COLLAB_KEY);
  static const event = TypeSearch(EVENT_KEY);
}
