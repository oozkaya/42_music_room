import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../constants/spotify_color_scheme.dart';
import '../../../models/_models.dart';
import '../../../providers/spotify_player_provider.dart';
import '../../../services/spotify/open_item.dart';
import '../../../utils/spotify/joinArtistsName.dart';

class QueueTrackTile extends StatelessWidget {
  final Object trackContainer;
  final dynamic track;
  final bool showImage;
  final int index;
  final TypeSearch containerType;
  final ValueKey key;
  final bool isEvent;
  final Function onDelete;
  final bool isCurrentTrack;

  QueueTrackTile(
    this.trackContainer,
    this.track,
    this.containerType, {
    this.showImage = false,
    this.index,
    this.key,
    this.isEvent,
    this.onDelete,
    this.isCurrentTrack,
  });

  String _getArtistsDescription(
      List<ArtistSimple> artists, bool isTrackExplicit) {
    String result = '';
    if (isTrackExplicit) result += "🅴 ";
    result += joinArtistsName(artists, separator: ", ");
    return result;
  }

  Widget _getImage() {
    if (track.album.images.length == 0) return Text('');
    final url = track.album.images.last.url;
    return Image.network(url);
  }

  @override
  Widget build(BuildContext context) {
    SpotifyPlayerProvider playerProvider =
        Provider.of<SpotifyPlayerProvider>(context);

    return track.name == ""
        ? Container()
        : Slidable(
            key: ObjectKey('$index:${track.uri}'),
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.2,
            child: Opacity(
              opacity: index < 0 ? 0.7 : 1,
              child: ListTile(
                key: key ?? ValueKey(track),
                leading: !showImage
                    ? null
                    : Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          index != null
                              ? SizedBox(
                                  width: 25,
                                  child: Text((index).toString()),
                                )
                              : Text(''),
                          showImage ? _getImage() : Text(''),
                        ],
                      ),
                title: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: track?.name,
                    style: TextStyle(
                      color: isCurrentTrack == true
                          ? Theme.of(context).colorScheme.green
                          : Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                subtitle: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: _getArtistsDescription(track.artists, track.explicit),
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
                      color: Theme.of(context).textTheme.caption.color,
                    ),
                  ),
                ),
                onTap: () {
                  if (index > 0) {
                    playerProvider.removeTrackQueueAt(index - 1);
                  }
                  openItem(
                      context, playerProvider, track, TypeSearch.track.key);
                },
              ),
            ),
            actions: index <= 0
                ? []
                : <Widget>[
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () => playerProvider.removeTrackQueueAt(index - 1),
                    ),
                  ],
          );
  }
}
