import 'dart:async';

import 'package:flutter/material.dart';

import '../../../constants/spotify_color_scheme.dart';
import './toast_animation.dart';

enum ToastLevel {
  Info,
  Warn,
  Error,
}

_getColors(BuildContext context, ToastLevel level) {
  if (level == ToastLevel.Info) {
    return {
      'font': Color(0xFFFFFFFF),
      'background': Theme.of(context).colorScheme.green
    };
  } else if (level == ToastLevel.Warn) {
    return {
      'font': Theme.of(context).colorScheme.darkGray,
      'background': Color(0xffffc107)
    };
  } else {
    return {'font': Color(0xFFFFFFFF), 'background': Color(0xffe53e3f)};
  }
}

class ToastUtils {
  static Timer toastTimer;
  static OverlayEntry _overlayEntry;

  static void showCustomToast(
    BuildContext context,
    String message, {
    num durationSec = 5,
    ToastLevel level = ToastLevel.Info,
  }) {
    Duration duration = Duration(seconds: durationSec);
    if (toastTimer == null || !toastTimer.isActive) {
      _overlayEntry = createOverlayEntry(context, message, duration, level);
      Overlay.of(context).insert(_overlayEntry);
      toastTimer = Timer(duration, () {
        if (_overlayEntry != null) {
          _overlayEntry.remove();
        }
      });
    }
  }

  static OverlayEntry createOverlayEntry(BuildContext context, String message,
      Duration duration, ToastLevel level) {
    return OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        width: MediaQuery.of(context).size.width,
        child: Dismissible(
          key: Key('toast'),
          onDismissed: (_) {
            _overlayEntry.remove();
            toastTimer = null;
          },
          child: ToastMessageAnimation(
            duration: duration,
            child: Material(
              elevation: 10.0,
              child: Container(
                padding:
                    EdgeInsets.only(left: 10, right: 10, top: 13, bottom: 10),
                decoration: BoxDecoration(
                  color: _getColors(context, level)['background'],
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 15,
                      color: _getColors(context, level)['font'],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
