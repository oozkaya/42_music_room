import 'dart:async';

import 'package:MusicRoom42/models/_models.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
// import 'package:logger/logger.dart';
import 'package:osm_nominatim/osm_nominatim.dart';

import '../../../../../../../../app_localizations.dart';
import 'build_map.dart';

import '../../../../../../../../utils/logger.dart';

class MapScreen extends StatefulWidget {
  final EventSettings currentSettings;
  final Function updateSettings;

  const MapScreen(this.currentSettings, this.updateSettings);

  @override
  _MapScreenState createState() => _MapScreenState();

  // static _MapScreenState of(BuildContext context) =>
  //     context.findAncestorStateOfType<_MapScreenState>();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "";
  String currentPlaceName = "";
  List<Place> searchResult = [];
  Place selectedPlace;
  MapController mapController;
  StreamSubscription subscription;
  bool hasMapMoved = false;
  LatLng initialMapCenter;

  @override
  void initState() {
    initialMapCenter =
        widget.currentSettings?.voteRestrictions?.locationLatLng ??
            LatLng(48.896682999999996, 2.318387963450124); // 42 campus at Paris
    currentPlaceName =
        widget.currentSettings?.voteRestrictions?.locationName ?? "";
    if (currentPlaceName == "") {
      updateCurrentAddress(position: initialMapCenter);
    }

    mapController = MapController();
    mapController.onReady.then((_) {
      subscription = mapController.mapEventStream.listen((MapEvent mapEvent) {
        if (mapEvent is MapEventMoveEnd) {
          updateCurrentAddress();
          checkHasMoved();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    mapController = null;
    subscription.cancel();
    super.dispose();
  }

  checkHasMoved() async {
    var position = mapController.center;
    if (position != null && position != initialMapCenter) {
      setState(() => hasMapMoved = true);
    }
  }

  updateCurrentAddress({LatLng position}) async {
    var center = position ?? mapController?.center;
    if (center == null) return;

    try {
      var place = await Nominatim.reverseSearch(
        lat: center.latitude,
        lon: center.longitude,
        addressDetails: false,
        extraTags: false,
        nameDetails: false,
      );
      setState(() {
        currentPlaceName = place.displayName;
      });
    } catch (err) {
      CustomLogger().e(err);
    }
  }

  searchLocationsByName(String query) async {
    try {
      searchResult = await Nominatim.searchByName(
        query: query,
        limit: 3,
        addressDetails: false,
        extraTags: false,
        nameDetails: false,
      );
      setState(() {});
    } catch (_) {}
  }

  void centerToLocation(Place place) {
    if (place == null || mapController == null) return;

    var latLng = LatLng(place.lat, place.lon);
    mapController.move(latLng, 16.0);
    setState(() {
      selectedPlace = place;
      searchResult = [];
      currentPlaceName = place.displayName;
    });
  }

  void updateSearchQuery(String newQuery) {
    searchQuery = newQuery;
  }

  void _stopSearching() {
    setState(() {
      _isSearching = false;
      _searchQueryController.clear();
      updateSearchQuery("");
      searchResult = [];
    });
  }

  void _startSearch() {
    ModalRoute.of(context)
        .addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  Widget _buildAppBarSearchField() {
    return TextField(
      controller: _searchQueryController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: "Search location...",
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white30),
      ),
      cursorColor: Theme.of(context).accentColor,
      style: TextStyle(color: Colors.white, fontSize: 16.0),
      onChanged: (query) => updateSearchQuery(query),
      onSubmitted: (query) => searchLocationsByName(query),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            runZonedGuarded(() {
              if (_searchQueryController == null ||
                  _searchQueryController.text.isEmpty) {
                Navigator.pop(context);
                return;
              }
              _stopSearching();
            }, (error, stackTrace) {
              FirebaseCrashlytics.instance.recordError(error, stackTrace);
            });
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          runZonedGuarded(() {
            _startSearch();
          }, (error, stackTrace) {
            FirebaseCrashlytics.instance.recordError(error, stackTrace);
          });
        },
      ),
    ];
  }

  Widget _buildSearchResult(double appBarHeight) {
    if (searchResult.isEmpty) return Container();

    return Column(
      children: searchResult
          .map((result) => ListTile(
                tileColor: Theme.of(context).backgroundColor.withAlpha(0xcc),
                leading: result.icon != null
                    ? Image.network(result.icon,
                        color: Theme.of(context).colorScheme.onPrimary)
                    : Icon(Icons.location_on_outlined),
                title:
                    Text(result.displayName, overflow: TextOverflow.ellipsis),
                onTap: () {
                  centerToLocation(result);
                  checkHasMoved();
                  _stopSearching();
                  Navigator.pop(context);
                },
              ))
          .toList(),
    );
  }

  Widget _buildAddressTextBox() {
    return currentPlaceName.length == 0
        ? Container()
        : Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0, left: 0.0, right: 0.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 5.0, color: Colors.white),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 80.0,
                  child: Container(
                    decoration: new BoxDecoration(
                      color: Colors.green[200].withAlpha(0xdd),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 10, 80, 10),
                      child: Text(
                        currentPlaceName,
                        overflow: TextOverflow.clip,
                        style: TextStyle(color: Colors.grey[900]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  validateLocation() {
    var updatedSettings = EventSettings.from(widget.currentSettings);
    updatedSettings.voteRestrictions.locationLatLng = mapController?.center;
    updatedSettings.voteRestrictions.locationName = currentPlaceName;
    widget.updateSettings(updatedSettings);
    Navigator.of(context).pop();
  }

  Widget _buildValidationButton({bool isEnabled}) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15.0, right: 15.0),
        child: FloatingActionButton(
          backgroundColor: isEnabled
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          child: Icon(
            Icons.check,
            color: Colors.white,
          ),
          onPressed: () {
            runZonedGuarded(() {
              if (isEnabled) validateLocation();
            }, (error, stackTrace) {
              FirebaseCrashlytics.instance.recordError(error, stackTrace);
            });
          },
        ),
      ),
    );
  }

  Future<bool> onCancel(BuildContext context) async {
    if (hasMapMoved == false) {
      Navigator.of(context).pop(true);
      return true;
    }
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context).translate('alertAreYouSure'),
            ),
            content: Text(
              AppLocalizations.of(context)
                  .translate('alertGoBackWithoutSaving'),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  runZonedGuarded(() {
                    Navigator.of(context).pop(true);
                  }, (error, stackTrace) {
                    FirebaseCrashlytics.instance.recordError(error, stackTrace);
                  });
                },
                child: Text(
                  AppLocalizations.of(context).translate('alertDialogQuitBtn'),
                ),
              ),
              FlatButton(
                color: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                onPressed: () {
                  runZonedGuarded(() {
                    Navigator.of(context).pop(false);
                  }, (error, stackTrace) {
                    FirebaseCrashlytics.instance.recordError(error, stackTrace);
                  });
                },
                child: Text(
                  AppLocalizations.of(context).translate('alertSaveFirst'),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  Widget build(BuildContext context) {
    var wasLocationEmpty =
        widget.currentSettings?.voteRestrictions?.locationLatLng == null;

    var appBar = AppBar(
      leading: _isSearching ? Container() : const BackButton(),
      title: _isSearching
          ? _buildAppBarSearchField()
          : Text('Select event location'),
      actions: _buildAppBarActions(),
      shadowColor: Colors.black,
    );

    return WillPopScope(
      onWillPop: () => onCancel(context),
      child: Scaffold(
        appBar: appBar,
        body: Stack(
          children: [
            BuildMap(mapController, updateCurrentAddress, initialMapCenter),
            _buildSearchResult(appBar.preferredSize.height),
            _buildAddressTextBox(),
            _buildValidationButton(isEnabled: wasLocationEmpty || hasMapMoved),
            Center(
              child: Icon(
                Icons.location_pin,
                size: 40.0,
                color: Theme.of(context).accentColor.withAlpha(0xdd),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
