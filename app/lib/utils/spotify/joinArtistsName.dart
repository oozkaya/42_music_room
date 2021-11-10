String joinArtistsName(List<dynamic> artists, {String separator = ", "}) {
  if (artists == null) return '';
  return artists.map((artist) => artist.name).toList().join(separator);
}
