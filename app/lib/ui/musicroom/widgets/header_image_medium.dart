import 'dart:async';
import 'dart:developer';
import 'dart:math';
import 'dart:typed_data';

import 'package:MusicRoom42/models/_models.dart';
import 'package:MusicRoom42/ui/utils/toast/toast_utils.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' hide Image;

import '../../../app_localizations.dart';
import '../../../providers/spotify_player_provider.dart';
import '../../../services/spotify/open_item.dart';

class HeaderImageMedium extends StatefulWidget {
  final dynamic trackContainer;
  final String itemUri;
  final Color backgroundColor;
  final Uint8List imageBytes;
  final String title;
  final String subtitle;
  final String subtitle2;
  final double distanceKmFromEvent;
  final bool disableButton;

  HeaderImageMedium({
    this.trackContainer,
    this.itemUri,
    this.backgroundColor,
    this.imageBytes,
    this.title,
    this.subtitle,
    this.subtitle2,
    this.distanceKmFromEvent,
    this.disableButton,
  });

  @override
  _HeaderImageMediumState createState() => _HeaderImageMediumState();
}

class _HeaderImageMediumState extends State<HeaderImageMedium> {
  double topPaddingHeight = 50;

  Widget buildRestrictions(BuildContext context) {
    Widget timeRestrictions;
    Widget locationRestrictions;
    var event = widget.trackContainer as EventModel;

    topPaddingHeight = 50;
    if (event.settings?.isTimeRestrictionEnabled == true) {
      topPaddingHeight /= 2;
      var formatter = DateFormat('dd/MM/yy - HH:dd');
      var now = DateTime.now();
      var startDate = event.settings?.voteRestrictions?.startDate;
      var endDate = event.settings?.voteRestrictions?.endDate;
      var hasStarted = startDate == null || startDate.isBefore(now);
      var isFinished = endDate != null && endDate.isBefore(now);
      var eventIconColor = !hasStarted
          ? Colors.green[100]
          : isFinished
              ? Colors.red[800]
              : Theme.of(context).accentColor;
      timeRestrictions = SizedBox(
        height: 35,
        child: ListTile(
            dense: true,
            leading: Icon(
              Icons.event,
              color: eventIconColor,
              size: 24,
            ),
            title: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                startDate != null
                    ? Text(
                        'From: ' + formatter.format(startDate),
                        style: Theme.of(context).textTheme.bodyText1,
                      )
                    : Container(),
                endDate != null
                    ? Text(
                        'To: ' + formatter.format(endDate),
                        style: Theme.of(context).textTheme.bodyText1,
                      )
                    : Container(),
              ],
            )),
      );
    }
    if (event.settings?.isLocationRestrictionEnabled == true) {
      topPaddingHeight /= 2;
      var distance = widget.distanceKmFromEvent;
      var distanceTxt = distance == null
          ? 'Unavailable'
          : distance.toStringAsFixed(2) + ' km';
      var pinColor = distance == null
          ? Theme.of(context).colorScheme.secondary
          : distance <= 0.2
              ? Theme.of(context).accentColor
              : Colors.red[300];
      locationRestrictions = InkWell(
        onTap: () {
          var latLng = event.settings?.voteRestrictions?.locationLatLng;
          MapsLauncher.launchCoordinates(latLng.latitude, latLng.longitude);
        },
        child: ListTile(
          dense: true,
          trailing: Wrap(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.location_pin, color: pinColor, size: 24),
              Text(
                distanceTxt,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyText1.fontSize,
                  color: pinColor,
                ),
              ),
            ],
          ),
          title: Text(
            event.settings.voteRestrictions.locationName ??
                'Restricted location',
            maxLines: 2,
            style: Theme.of(context).textTheme.bodyText1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return Column(
      children: [
        timeRestrictions ?? Container(),
        locationRestrictions ?? Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SpotifyPlayerProvider playerProvider =
        Provider.of<SpotifyPlayerProvider>(context, listen: false);

    inspect(widget.trackContainer);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          colors: [
            widget.backgroundColor.withAlpha(0xaa),
            Theme.of(context).scaffoldBackgroundColor,
          ],
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            widget.trackContainer is EventModel
                ? buildRestrictions(context)
                : Container(),
            SizedBox(height: topPaddingHeight),
            SizedBox(
              height: 150,
              child: widget.imageBytes == null
                  ? null
                  : Image.memory(widget.imageBytes),
            ),
            SizedBox(height: 10),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.headline5.fontSize,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              widget.subtitle,
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
            widget.subtitle2 != null
                ? Text(
                    widget.subtitle2,
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.center,
                  )
                : Container(),
            widget.disableButton == true ||
                    (widget.trackContainer?.tracks is List &&
                        (widget.trackContainer?.tracks ?? []).length == 0)
                ? SizedBox(height: 20)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(80, 10, 80, 10),
                    child: RaisedButton(
                      child: Text(
                          AppLocalizations.of(context)
                              .translate(widget.trackContainer is EventModel
                                  ? 'play'
                                  : "musicShufflePlay")
                              .toUpperCase(),
                          style: TextStyle(
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                          )),
                      textColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      onPressed: () {
                        runZonedGuarded(() {
                          if (widget.trackContainer is Collab) {
                            var tracks =
                                (widget.trackContainer as Collab).tracks;
                            if (tracks.length > 0) {
                              var randomTrack =
                                  tracks[Random().nextInt(tracks.length)];
                              openItem(context, playerProvider, randomTrack,
                                  TypeSearch.COLLAB_KEY,
                                  containerItem: widget.trackContainer,
                                  isShuffling: true);
                            } else {
                              ToastUtils.showCustomToast(
                                context,
                                AppLocalizations.of(context)
                                    .translate("shuffleNeedTracks"),
                              );
                            }
                          } else if (widget.trackContainer is EventModel) {
                            var tracks =
                                (widget.trackContainer as EventModel).tracks;
                            openItem(context, playerProvider, tracks[0].track,
                                TypeSearch.EVENT_KEY,
                                containerItem: widget.trackContainer,
                                isShuffling: false);
                          } else {
                            playBySpotifyUri(
                              context,
                              playerProvider,
                              widget.itemUri,
                              isShuffle: true,
                            );
                          }
                        }, (error, stackTrace) {
                          FirebaseCrashlytics.instance
                              .recordError(error, stackTrace);
                        });
                      },
                    ),
                  ),
          ]),
    );
  }
}
