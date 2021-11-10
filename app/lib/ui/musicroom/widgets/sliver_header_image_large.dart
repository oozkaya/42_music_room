import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify/spotify.dart' as Spotify;

import '../../../app_localizations.dart';
import '../../../models/_models.dart';
import '../../../providers/spotify_player_provider.dart';
import '../../../services/spotify/open_item.dart';
import '../../utils/toast/toast_utils.dart';
import '../subpages/item_menu/item_menu.dart';

class SliverHeaderImageLarge extends SliverPersistentHeaderDelegate {
  final Color backgroundColor;
  final Uint8List imageBytes;
  final String itemUri;
  final String title;
  final String subtitle;
  final Spotify.Artist artist;

  SliverHeaderImageLarge(
      {this.backgroundColor,
      this.imageBytes,
      this.itemUri,
      this.title,
      this.subtitle,
      this.artist});

  @override
  double get maxExtent => 400;

  @override
  double get minExtent => 110;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    SpotifyPlayerProvider playerProvider =
        Provider.of<SpotifyPlayerProvider>(context, listen: false);

    final double _appTopBarHeight = 90;
    var shrinkPercentage =
        min(1, shrinkOffset / (maxExtent - minExtent)).toDouble();

    Widget _appBar() {
      return Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Container(
          height: _appTopBarHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    runZonedGuarded(() {
                      Navigator.of(context).pop();
                    }, (error, stackTrace) {
                      FirebaseCrashlytics.instance
                          .recordError(error, stackTrace);
                    });
                  },
                ),
                Flexible(
                  child: Opacity(
                    opacity: shrinkPercentage,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {
                    runZonedGuarded(() {
                      if (this.artist != null) {
                        Navigator.of(context).push(ItemMenu(
                            this.artist, TypeSearch.artist, context,
                            showArtists: false, lightArtist: true));
                      } else {
                        ToastUtils.showCustomToast(
                            context, 'Not implementeddd');
                      }
                    }, (error, stackTrace) {
                      FirebaseCrashlytics.instance
                          .recordError(error, stackTrace);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _artistImage() {
      return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            flex: 1,
            child: Opacity(
              opacity: 1 - shrinkPercentage,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      backgroundColor.withAlpha(0xdd),
                      Theme.of(context).scaffoldBackgroundColor.withAlpha(0x00),
                    ],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.dstATop,
                child: imageBytes == null
                    ? Container(
                        color: backgroundColor,
                      )
                    : Image.memory(
                        imageBytes,
                        fit: BoxFit.fitWidth,
                      ),
              ),
            ),
          ),
        ],
      );
    }

    Widget _artistDescription() {
      return Positioned(
        top: MediaQuery.of(context).size.width / 2,
        left: 0,
        right: 0,
        child: Opacity(
          opacity: max(1 - shrinkPercentage * 6, 0),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.headline4.fontSize,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                subtitle.toUpperCase(),
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.caption.fontSize,
                  color: Theme.of(context).textTheme.caption.color,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    Widget _shuffleButton() {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(80, 15, 80, 0),
          child: Center(
            child: RaisedButton(
              child: Text(
                  AppLocalizations.of(context)
                      .translate("musicShufflePlay")
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
                  playBySpotifyUri(
                    context,
                    playerProvider,
                    itemUri,
                    isShuffle: true,
                  );
                }, (error, stackTrace) {
                  FirebaseCrashlytics.instance.recordError(error, stackTrace);
                });
              },
            ),
          ),
        ),
      );
    }

    return Stack(
      overflow: Overflow.clip,
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: _appTopBarHeight,
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        _artistImage(),
        Stack(
          overflow: Overflow.clip,
          fit: StackFit.expand,
          children: [
            _appBar(),
            _artistDescription(),
            _shuffleButton(),
          ],
        ),
      ],
    );
  }
}
