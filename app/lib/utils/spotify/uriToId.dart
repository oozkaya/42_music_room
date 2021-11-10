String uriToId(String uri) {
  var pos = uri.lastIndexOf(':');
  return (pos != -1) ? uri.substring(pos + 1) : uri;
}
