import 'dart:typed_data';

import 'package:MusicRoom42/services/spotify/set_status.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
// import 'package:transparent_image/transparent_image.dart';

import '../../../providers/spotify_player_provider.dart';

class PlayerImageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<SpotifyPlayerProvider, ImageUri>(
        selector: (_, model) => model?.track?.imageUri,
        builder: (_, imageUri, __) {
          return Container(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FutureBuilder<Uint8List>(
                  future: SpotifySdk.getImage(imageUri: imageUri),
                  builder: (context, snapshot) {
                    if (snapshot.hasData & !snapshot.hasError) {
                      Provider.of<SpotifyPlayerProvider>(context, listen: false)
                          .getBackgroundColor(snapshot.data);
                      return Image.memory(snapshot.data, gaplessPlayback: true);
                      // return FadeInImage(
                      //   placeholder: Image.memory(kTransparentImage).image,
                      //   image: Image.memory(snapshot.data).image,
                      // );
                      // } else if (snapshot.hasError) {
                      //   setStatus('getImage: ',
                      //       message: snapshot.error.toString());
                      //   return SizedBox(
                      //     width: ImageDimension.large.value.toDouble(),
                      //     height: ImageDimension.large.value.toDouble(),
                      //     child: const Center(child: Text('Error getting image')),
                      //   );
                    }
                    return Center(child: CircularProgressIndicator());
                  }),
            ),
            height: 325,
            width: 325,
          );
        });
  }
}
