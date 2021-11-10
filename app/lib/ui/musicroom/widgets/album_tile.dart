import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../services/spotify/open_item.dart';
import '../../../utils/dart/stringsExtension.dart';

class AlbumTile extends StatelessWidget {
  final Album album;

  AlbumTile(this.album);

  String _getAlbumDescription() {
    final String type = album.albumType.capitalize();
    var dateFormatters = {
      'DatePrecision.year': "yyyy",
      'DatePrecision.month': "yyyy-MM",
      'DatePrecision.day': "yyyy-MM-dd",
    };
    var formatter = dateFormatters[album.releaseDatePrecision.toString()];
    final DateTime releaseDate = DateFormat(formatter).parse(album.releaseDate);
    return "$type • ${releaseDate.year}";
  }

  Widget _getImage() {
    if (album.images.length == 0) return Text('');
    final url = album.images.last.url;
    return Image.network(url);
  }

  @override
  Widget build(BuildContext context) {
    return album.name == ""
        ? Container()
        : ListTile(
            leading: _getImage(),
            title: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(text: album.name),
            ),
            subtitle: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: _getAlbumDescription(),
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
                  color: Theme.of(context).textTheme.caption.color,
                ),
              ),
            ),
            onTap: () => handleOpenAlbum(context, album.id),
          );
  }
}
