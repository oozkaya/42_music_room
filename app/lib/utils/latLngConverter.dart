import 'package:json_annotation/json_annotation.dart';
import 'package:latlong/latlong.dart';

class LatLngConverter implements JsonConverter<LatLng, String> {
  const LatLngConverter();

  @override
  LatLng fromJson(String latLng) {
    if (latLng == null) return null;

    List<String> array = latLng.split(",");
    if (array.length != 2) return null;
    double latitude = double.parse(array[0]);
    double longitude = double.parse(array[1]);
    return LatLng(latitude, longitude);
  }

  @override
  String toJson(LatLng latLng) => '${latLng?.latitude},${latLng?.longitude}';
}
