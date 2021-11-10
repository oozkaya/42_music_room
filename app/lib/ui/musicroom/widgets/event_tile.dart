import 'dart:math';

import 'package:MusicRoom42/providers/spotify_app_provider.dart';
import 'package:MusicRoom42/ui/musicroom/subpages/event/event_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/_models.dart';

class EventTile extends StatefulWidget {
  final EventModel event;
  final String name;
  final String description;
  final Widget leading;
  final Function onTap;
  final bool isSearchTile;
  final Function ancestorSetState;

  EventTile({
    this.event,
    this.name,
    this.description,
    this.leading,
    this.onTap,
    this.isSearchTile = false,
    this.ancestorSetState,
  });

  @override
  _EventTileState createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  String name;
  String description;
  Widget leading;
  Function onTap;

  Widget _leading() {
    return Container(
      width: widget.isSearchTile ? 40 : 55,
      height: widget.isSearchTile ? 40 : 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
            Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: _getRightsIcons(),
      ),
    );
  }

  List<Widget> _getRightsIcons() {
    List<Widget> list = List();

    var currentUser = FirebaseAuth.instance.currentUser;
    var isAdmin = widget.event.adminUserId == currentUser.uid;
    var rights = widget.event.usersRights;
    var userRights = rights != null
        ? rights[currentUser.uid] ?? EventUsersRights()
        : EventUsersRights();

    if (isAdmin || widget.event.isPublic || userRights.read == true) {
      list.add(Icon(Icons.remove_red_eye, size: 20));
    }
    if (isAdmin || userRights.edit == true) {
      list.add(Icon(Icons.edit, size: 20));
    }
    if (userRights.vote == true) {
      list.add(Icon(Icons.arrow_upward, size: 20));
    }
    if (isAdmin) {
      list.add(Icon(Icons.settings, size: 20));
    }
    return list;
  }

  @override
  initState() {
    final spotifyAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);

    name = widget.event?.name ?? widget.name;
    description = widget.isSearchTile
        ? 'Event'
        : widget.event?.adminUsername != null
            ? 'by ${widget.event.adminUsername}'
            : widget.description;
    leading = widget.leading ?? _leading();
    if (widget.onTap != null)
      onTap = (ctx) => widget.onTap(ctx);
    else
      onTap = (ctx) => Navigator.of(ctx)
              .push(MaterialPageRoute(
                  builder: (ctx) => EventScreen(
                      spotifyAppProvider.spotifyApi, widget.event.id)))
              .then((_) {
            if (widget.ancestorSetState != null) widget.ancestorSetState(() {});
          });
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
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary),
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
