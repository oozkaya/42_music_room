import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../services/spotify/open_item.dart';

Widget _getImage(playlist) {
  if (playlist.images.length == 0)
    return Icon(Icons.music_note_outlined, size: 55.0);
  final url = playlist.images.last.url;
  return Image.network(url);
}

class PlaylistTile extends StatefulWidget {
  final PlaylistSimple playlist;
  final String name;
  final String description;
  final Widget leading;
  final Function onTap;

  PlaylistTile(
      {this.playlist, this.name, this.description, this.leading, this.onTap});

  @override
  _PlaylistTileState createState() => _PlaylistTileState();
}

class _PlaylistTileState extends State<PlaylistTile> {
  String name;
  String description;
  Widget leading;
  Function onTap;

  @override
  initState() {
    if (widget.playlist != null) {
      name = widget.playlist.name;
      description = 'by ${widget.playlist.owner.displayName}';
      leading = _getImage(widget.playlist);
      onTap = (ctx) => handleOpenPlaylist(ctx, widget.playlist.id);
    } else {
      name = widget.name;
      description = widget.description;
      leading = widget.leading;
      onTap = (ctx) => widget.onTap(ctx);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return name == ""
        ? Container()
        : ListTile(
            leading: leading,
            title: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: name,
                style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            subtitle: description == null
                ? null
                : RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: description,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.subtitle2.fontSize,
                        color: Theme.of(context).textTheme.caption.color,
                      ),
                    ),
                  ),
            onTap: () => onTap(context),
          );
  }
}
