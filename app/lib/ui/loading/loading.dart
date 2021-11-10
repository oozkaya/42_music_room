import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Image(
            image: AssetImage('assets/images/spotify_loading.gif'),
            height: 200,
          ),
        ));
  }
}
