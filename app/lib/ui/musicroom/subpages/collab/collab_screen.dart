import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pagination_view/pagination_view.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../../app_localizations.dart';
import '../../../../constants/spotify_color_scheme.dart';
import '../../../../models/_models.dart';
import '../../../../providers/spotify_app_provider.dart';
import '../../../../services/firestore/collections/collabs_collection.dart';
import '../../../../utils/getImagePalette.dart';
import '../../widgets/header_image_medium.dart';
import '../../widgets/track_tile.dart';
import './collab_settings.dart' as CollabSettings;
import './collab_like.dart';

class CollabScreen extends StatefulWidget {
  final SpotifyApi spotifyApi;
  final String collabId;

  CollabScreen(this.spotifyApi, this.collabId);

  @override
  _CollabScreenState createState() => _CollabScreenState();
}

class _CollabScreenState extends State<CollabScreen> {
  Uint8List collabImageBytes;
  Color backgroundColor;
  Collab collab;
  bool sortTracks = false;
  bool showMenu = true;
  CollabsCollection collabsCollection = CollabsCollection();
  bool isAdmin;
  CollabUserRights userRights;

  int page;
  GlobalKey<PaginationViewState> key;

  @override
  void initState() {
    page = -1;
    key = GlobalKey<PaginationViewState>();
    super.initState();
  }

  getCollabImage() {
    if (collab != null && collab.tracks != null && collab.tracks.length > 0) {
      var firstTrack = collab.tracks.first;
      if (firstTrack != null && firstTrack.album != null) {
        var album = firstTrack.album;
        if (album.images != null && album.images.length > 0) {
          return album.images[1].url;
        }
      }
    }
    return null;
  }

  refreshImagesAndColor() async {
    var imageUrl = getCollabImage();
    var palette = await getImagePalette(imgUrl: imageUrl);
    backgroundColor = palette.favorite;
    collabImageBytes = palette.imageBytes;
  }

  Future<bool> refreshCollab(Collab updatedCollab) async {
    collab = updatedCollab;
    await refreshImagesAndColor();

    var currentUser = FirebaseAuth.instance.currentUser;
    isAdmin = collab.adminUserId == currentUser.uid;
    if (isAdmin || collab.rights.isEditionPublic)
      userRights = CollabUserRights(write: true);
    else
      userRights =
          collab.rights.usersRights[currentUser.uid] ?? CollabUserRights();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final SpotifyRemoteAppProvider spotifyAppProvider =
        Provider.of<SpotifyRemoteAppProvider>(context, listen: false);

    String _getCollabDescription() {
      final Map<String, dynamic> translateValues = {
        'owner': collab.adminUsername
      };
      return AppLocalizations.of(context)
          .translate("musicCollabDescription", translateValues);
    }

    String _getRightsDescription() {
      if (isAdmin) return "Admin";
      String rights = '';
      var canRead = collab.rights.isVisibilityPublic || userRights.read == true;
      var canWrite = collab.rights.isEditionPublic || userRights.write == true;
      if (canRead) rights += 'Read';
      if (canWrite) rights += ' Write';
      return rights;
    }

    Function onDeleteTrack(indexTrack, trackId) {
      if (userRights.write == false) return null;
      return () async {
        var updatedCollab = await CollabsCollection()
            .remoteTrack(collab.id, indexTrack, trackId);
        setState(() {
          collab = updatedCollab;
          if (indexTrack <= 3) refreshImagesAndColor();
        });
      };
    }

    List<TrackTile> getTrackList() {
      List<TrackTile> tiles = List();
      collab.tracks.asMap().forEach((index, track) {
        if (track != null) {
          tiles.add(
            TrackTile(
              collab,
              track,
              TypeSearch.playlist,
              showImage: true,
              key: ValueKey(track),
              draggable: sortTracks,
              isEvent: false,
              onDelete: onDeleteTrack(index, track.id),
            ),
          );
        }
      });
      return tiles;
    }

    HeaderImageMedium getHeader() {
      return HeaderImageMedium(
        backgroundColor:
            backgroundColor ?? Theme.of(context).colorScheme.mediumGray,
        imageBytes: collabImageBytes,
        trackContainer: collab,
        itemUri: collab.id,
        title: collab.name,
        subtitle: _getCollabDescription(),
        subtitle2: _getRightsDescription(),
      );
    }

    Widget buildScreen() {
      return Scaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          title: Text(
            collab.name,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          actions: <Widget>[
            CollabLike(
              collab,
              isAdmin: isAdmin,
              userRights: userRights,
            ),
            CollabSettings.CollabSettings(
              context,
              collab,
              spotifyAppProvider,
              onSortEdit: () {
                setState(() => this.sortTracks = !this.sortTracks);
              },
              isAdmin: isAdmin,
              userRights: userRights,
            ),
          ],
        ),
        body: Container(
          child: SizedBox(
            height: 1000,
            child: sortTracks == true
                ? ReorderableListView(
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        var tmp = collab.tracks.removeAt(oldIndex);
                        if (newIndex > oldIndex) {
                          newIndex--;
                        }
                        collab.tracks.insert(newIndex, tmp);
                        CollabsCollection()
                            .update(collab.id, collab)
                            .then((collab) {
                          setState(() {
                            collab = collab;
                          });
                        });
                      });
                    },
                    key: key,
                    header: getHeader(),
                    children: getTrackList())
                : ListView(
                    children: [
                      getHeader(),
                      ...getTrackList(),
                    ],
                  ),
          ),
        ),
      );
    }

    return StreamBuilder(
        stream: CollabsCollection().documentStream(widget.collabId),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snap) {
          if (!snap.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            var data = snap.data.data();
            if (data == null) return Center(child: CircularProgressIndicator());
            var newCollab = Collab.fromJson(data, snap.data.id);
            return FutureBuilder(
                future: refreshCollab(newCollab),
                builder: (BuildContext context, AsyncSnapshot<bool> snap) {
                  if (!snap.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return buildScreen();
                  }
                });
          }
        });
  }
}
