import 'package:flutter/material.dart';

import '../../../../app_localizations.dart';

class T10Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Text(
        AppLocalizations.of(context).translate("top10World"),
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
