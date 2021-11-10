import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_localizations.dart';
import '../../constants/spotify_color_scheme.dart';
import '../../providers/language_provider.dart';

enum LanguagesActions { english, french }

class SettingLanguageActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider = Provider.of(context);
    Locale _appCurrentLocale = languageProvider.appLocale;

    return PopupMenuButton<LanguagesActions>(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.grey[300]
          : Theme.of(context).colorScheme.mediumGray,
      shape: Border(
        left: BorderSide(
          width: 4,
          color: Theme.of(context).accentColor,
          style: BorderStyle.solid,
        ),
      ),
      icon: Icon(Icons.language),
      onSelected: (LanguagesActions result) {
        switch (result) {
          case LanguagesActions.english:
            languageProvider.updateLanguage("en");
            break;
          case LanguagesActions.french:
            languageProvider.updateLanguage("fr");
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<LanguagesActions>>[
        PopupMenuItem<LanguagesActions>(
          value: LanguagesActions.english,
          enabled: _appCurrentLocale == Locale("en") ? false : true,
          child: Text(AppLocalizations.of(context)
              .translate("settingPopUpToggleEnglish")),
        ),
        PopupMenuItem<LanguagesActions>(
          value: LanguagesActions.french,
          enabled: _appCurrentLocale == Locale("fr") ? false : true,
          child: Text(AppLocalizations.of(context)
              .translate("settingPopUpToggleFrench")),
        ),
      ],
    );
  }
}
