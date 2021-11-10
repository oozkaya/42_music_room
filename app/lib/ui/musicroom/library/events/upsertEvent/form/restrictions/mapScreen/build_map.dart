import 'dart:async';
import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location/flutter_map_location.dart';
import 'package:latlong/latlong.dart';
import 'package:osm_nominatim/osm_nominatim.dart';

class BuildMap extends StatelessWidget {
  final MapController mapController;
  final Function updateCurrentAddress;
  final LatLng initialMapCenter;

  BuildMap(
    this.mapController,
    this.updateCurrentAddress,
    this.initialMapCenter,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: initialMapCenter,
          zoom: 16.0,
          minZoom: 2.0,
          maxZoom: 18.0,
          interactiveFlags: InteractiveFlag.all &
              ~InteractiveFlag.rotate &
              ~InteractiveFlag.pinchMove,
          plugins: <MapPlugin>[
            LocationPlugin(),
          ],
          onPositionChanged: (MapPosition position, bool hasGesture) {},
        ),
        layers: <LayerOptions>[
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: <String>['a', 'b', 'c'],
          ),
        ],
        nonRotatedLayers: <LayerOptions>[
          LocationOptions(
            initiallyRequest: false,
            markers: [],
            buttonBuilder: locationButton(),
            onLocationRequested: (LatLngData ld) {
              if (ld == null) return;
              mapController?.move(ld.location, 16.0);
              updateCurrentAddress();
            },
          ),
        ],
      ),
    );
  }

  LocationButtonBuilder locationButton() {
    return (BuildContext context, ValueNotifier<LocationServiceStatus> status,
        Function onPressed) {
      return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 90.0, right: 15.0),
          child: FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              child: ValueListenableBuilder<LocationServiceStatus>(
                  valueListenable: status,
                  builder: (BuildContext context, LocationServiceStatus value,
                      Widget child) {
                    switch (value) {
                      case LocationServiceStatus.disabled:
                      case LocationServiceStatus.permissionDenied:
                      case LocationServiceStatus.unsubscribed:
                        return const Icon(
                          Icons.location_disabled,
                          color: Colors.white,
                        );
                      default:
                        return const Icon(
                          Icons.location_searching,
                          color: Colors.white,
                        );
                    }
                  }),
              onPressed: () {
                runZonedGuarded(() {
                  onPressed();
                }, (error, stackTrace) {
                  FirebaseCrashlytics.instance.recordError(error, stackTrace);
                });
              }),
        ),
      );
    };
  }
}
