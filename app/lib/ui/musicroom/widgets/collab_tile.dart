import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/_models.dart';
import '../../../providers/spotify_app_provider.dart';
import '../subpages/collab/collab_screen.dart';

class CollabTile extends StatefulWidget {
  final Collab collab;
  final String name;
  final String description;
  final Widget leading;
  final Function onTap;
  final bool isSearchTile;
  final Function ancestorSetState;

  CollabTile({
    this.collab,
    this.name,
    this.description,
    this.leading,
    this.onTap,
    this.isSearchTile = false,
    this.ancestorSetState,
  });

  @override
  _CollabTileState createState() => _CollabTileState();
}

class _CollabTileState extends State<CollabTile> {
  String name;
  String description;
  Widget leading;
  Function onTap;

  List<Widget> _getRightsIcons() {
    List<Widget> list = [];

    var currentUser = FirebaseAuth.instance.currentUser;
    var isAdmin = widget.collab.adminUserId == currentUser.uid;
    var rights = widget.collab.rights;
    var userRights = rights.usersRights != null
        ? rights.usersRights[currentUser.uid] ?? CollabUserRights()
        : CollabUserRights();

    if (isAdmin || rights.isVisibilityPublic || userRights?.read == true)
      list.add(Icon(Icons.visibility, size: widget.isSearchTile ? 15 : 20));
    if (isAdmin || rights.isEditionPublic || userRights?.write == true)
      list.add(Icon(Icons.edit, size: widget.isSearchTile ? 15 : 20));
    if (isAdmin)
      list.add(Icon(Icons.settings, size: widget.isSearchTile ? 15 : 20));
    return list;
  }

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

  void _init() {
    final spotifyAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);

    name = widget.collab?.name ?? widget.name;
    description = widget.isSearchTile
        ? 'Collab'
        : widget.collab?.adminUsername != null
            ? 'by ${widget.collab?.adminUsername}'
            : widget.description;
    leading = widget.collab != null ? _leading() : widget.leading;
    if (widget.onTap != null)
      onTap = (ctx) => widget.onTap(ctx);
    else
      onTap = (ctx) => Navigator.of(ctx)
              .push(MaterialPageRoute(
                  builder: (ctx) => CollabScreen(
                      spotifyAppProvider.spotifyApi, widget.collab.id)))
              .then((_) {
            if (widget.ancestorSetState != null) widget.ancestorSetState(() {});
          });
  }

  @override
  Widget build(BuildContext context) {
    _init();

    return name == ""
        ? Container()
        : ListTile(
            key: UniqueKey(),
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
