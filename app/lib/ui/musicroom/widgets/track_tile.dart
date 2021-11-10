import 'dart:async';

import 'package:MusicRoom42/ui/utils/toast/toast_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../app_localizations.dart';
import '../../../constants/spotify_color_scheme.dart';
import '../../../models/_models.dart';
import '../../../providers/spotify_player_provider.dart';
import '../../../services/spotify/open_item.dart';
import '../../../utils/spotify/joinArtistsName.dart';
import '../subpages/item_menu/item_menu.dart';
import 'event_vote_button.dart';

class TrackTile extends StatefulWidget {
  final Object trackContainer;
  final dynamic track;
  final bool showImage;
  final int index;
  final TypeSearch containerType;
  final ValueKey key;
  final bool draggable;
  final bool isEvent;
  final Function onDelete;
  final double distanceKmFromEvent;

  TrackTile(
    this.trackContainer,
    this.track,
    this.containerType, {
    this.showImage = false,
    this.index,
    this.key,
    this.draggable,
    this.isEvent,
    this.onDelete,
    this.distanceKmFromEvent,
  });

  @override
  _TrackTileState createState() => _TrackTileState();
}

class _TrackTileState extends State<TrackTile> {
  dynamic _track;

  @override
  void initState() {
    if (widget.isEvent == true) {
      var eventTrack = widget.track as EventTrack;
      _track = eventTrack.track;
    } else {
      _track = widget.track;
    }
    super.initState();
  }

  String _getArtistsDescription(
      List<ArtistSimple> artists, bool isTrackExplicit) {
    String result = '';
    if (isTrackExplicit) result += "🅴 ";
    result += joinArtistsName(artists, separator: ", ");
    return result;
  }

  Widget _getImage() {
    if (_track.album.images.length == 0) return Text('');
    final url = _track.album.images.last.url;
    return Image.network(url);
  }

  Widget _trailing(BuildContext context) {
    Widget voteButton = Container();
    Widget actionButton = Container();
    if (widget.isEvent == true && widget.index > 0) {
      var event = widget.trackContainer as EventModel;
      var eventTrack = widget.track as EventTrack;
      voteButton =
          EventVoteButton(event, eventTrack, widget.distanceKmFromEvent);
    }

    if (widget.draggable == true) {
      actionButton = Icon(Icons.drag_handle);
    } else if (!(widget.isEvent == true && widget.index == 0)) {
      actionButton = Container(
        width: 30,
        child: IconButton(
          icon: Icon(Icons.more_vert),
          color: Theme.of(context).colorScheme.secondary,
          onPressed: () {
            runZonedGuarded(() {
              Navigator.of(context).push(ItemMenu(
                  _track, TypeSearch.track, context,
                  showArtists: this.widget.containerType != TypeSearch.artist,
                  showAlbum: this.widget.containerType != TypeSearch.album,
                  album: this.widget.containerType == TypeSearch.album
                      ? this.widget.trackContainer
                      : null,
                  isEvent: this.widget.isEvent,
                  onDelete: this.widget.onDelete));
            }, (error, stackTrace) {
              FirebaseCrashlytics.instance.recordError(error, stackTrace);
            });
          },
        ),
      );
    }

    return Container(
      width: widget.isEvent == true ? 80 : 40,
      padding: const EdgeInsets.all(0.0),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [voteButton, actionButton],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SpotifyPlayerProvider playerProvider =
        Provider.of<SpotifyPlayerProvider>(context);

    return _track.name == ""
        ? Container()
        : ListTile(
            key: widget.key ?? ValueKey(_track),
            leading: !widget.showImage
                ? null
                : Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      widget.index != null && widget.isEvent != true
                          ? SizedBox(
                              width: 25,
                              child: Text((widget.index + 1).toString()),
                            )
                          : Text(''),
                      widget.showImage ? _getImage() : Text(''),
                    ],
                  ),
            title: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: _track?.name,
                style: TextStyle(
                  color: playerProvider?.track?.uri == _track.uri
                      ? Theme.of(context).colorScheme.green
                      : Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            subtitle: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: _getArtistsDescription(_track.artists, _track.explicit),
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
                  color: Theme.of(context).textTheme.caption.color,
                ),
              ),
            ),
            trailing: _trailing(context),
            onTap: () {
              if (widget.trackContainer is Album) {
                playAlbumTrack(
                    context, playerProvider, widget.trackContainer, _track);
              } else if (widget.trackContainer is Playlist) {
                playPlaylistTrack(
                    context, playerProvider, widget.trackContainer, _track);
              } else if (widget.trackContainer is Artist) {
                playArtistTrack(
                    context, playerProvider, widget.trackContainer, _track);
              } else if (widget.trackContainer is Collab) {
                openItem(context, playerProvider, _track, TypeSearch.collab.key,
                    containerItem: widget.trackContainer);
              } else if (widget.trackContainer is EventModel) {
                ToastUtils.showCustomToast(
                  context,
                  AppLocalizations.of(context)
                      .translate("eventSongsNotClickable"),
                  level: ToastLevel.Info,
                  durationSec: 5,
                );
              } else {
                openItem(context, playerProvider, _track, TypeSearch.track.key);
              }
            },
          );
  }
}
