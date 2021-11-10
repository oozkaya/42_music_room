import 'package:location/location.dart';

Future<Location> initLocation() async {
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  Location location = new Location();

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return null;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }

  location.changeSettings(interval: 1000, distanceFilter: 10);

  return location;
}

// _currentPosition = await location.getLocation();
// location.onLocationChanged.listen((LocationData currentLocation) {});
