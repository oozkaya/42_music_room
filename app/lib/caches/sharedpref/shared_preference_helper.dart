import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotify/spotify.dart';

class SharedPreferenceHelper {
  Future<SharedPreferences> _sharedPreference;
  static const String is_dark_mode = "is_dark_mode";
  static const String language_code = "language_code";
  static const String credentials = "credentials";

  SharedPreferenceHelper() {
    _sharedPreference = SharedPreferences.getInstance();
  }

  //Theme module
  Future<void> changeTheme(bool value) {
    return _sharedPreference.then((prefs) {
      return prefs.setBool(is_dark_mode, value);
    });
  }

  Future<bool> get isDarkMode {
    return _sharedPreference.then((prefs) {
      return prefs.getBool(is_dark_mode) ?? true;
    });
  }

  //Locale module
  Future<String> get appLocale {
    return _sharedPreference.then((prefs) {
      return prefs.getString(language_code) ?? null;
    });
  }

  Future<void> changeLanguage(String value) {
    return _sharedPreference.then((prefs) {
      return prefs.setString(language_code, value);
    });
  }

  Future<void> setCredentials(SpotifyApiCredentials value) {
    return _sharedPreference.then((prefs) {
      var data = {
        'clientId': value.clientId,
        'clientSecret': value.clientSecret,
        'accessToken': value.accessToken,
        'refreshToken': value.refreshToken,
        'scopes': value.scopes,
        'expiration': value.expiration.toString(),
      };
      return prefs.setString(credentials, jsonEncode(data));
    });
  }

  Future<SpotifyApiCredentials> getCredentials() {
    return _sharedPreference.then((prefs) {
      if (prefs.containsKey(credentials)) {
        var data = jsonDecode(prefs.getString(credentials));
        List<String> scopes =
            (data['scopes'] as List).map((scope) => scope as String).toList();

        SpotifyApiCredentials cred = SpotifyApiCredentials(
          data['clientId'],
          data['clientSecret'],
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          scopes: scopes,
          expiration: DateTime.parse(data['expiration']),
        );

        return cred;
      }
      return null;
    });
  }
}
