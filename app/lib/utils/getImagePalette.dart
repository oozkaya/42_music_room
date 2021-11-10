import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';

class ImagePalette {
  Uint8List imageBytes;
  Color darkVibrant;
  Color dominant;
  Color favorite;
  Color lightVibrant;
  Color vibrant;

  ImagePalette({
    this.imageBytes,
    this.darkVibrant,
    this.dominant,
    this.favorite,
    this.lightVibrant,
    this.vibrant,
  });
}

Future<ImagePalette> getImagePalette(
    {Uint8List imgUint8List, String imgUrl}) async {
  Uint8List imageBytes;
  Color darkVibrant;
  Color dominant;
  Color lightVibrant;
  Color vibrant;

  imageBytes = imgUint8List;
  if (imgUint8List == null && imgUrl == null) {
    return ImagePalette();
  }
  if (imageBytes == null && imgUrl != null) {
    imageBytes = (await NetworkAssetBundle(Uri.parse(imgUrl)).load(imgUrl))
        .buffer
        .asUint8List();
  }

  var plt =
      await PaletteGenerator.fromImageProvider(Image.memory(imageBytes).image);
  vibrant = plt.vibrantColor != null ? plt.vibrantColor.color : null;
  darkVibrant =
      plt.darkVibrantColor != null ? plt.darkVibrantColor.color : null;
  lightVibrant =
      plt.lightVibrantColor != null ? plt.lightVibrantColor.color : null;
  dominant = plt.dominantColor != null ? plt.dominantColor.color : null;

  return ImagePalette(
    imageBytes: imageBytes,
    darkVibrant: darkVibrant,
    dominant: dominant,
    favorite: vibrant ?? darkVibrant ?? lightVibrant ?? dominant,
    lightVibrant: lightVibrant,
    vibrant: vibrant,
  );
}
