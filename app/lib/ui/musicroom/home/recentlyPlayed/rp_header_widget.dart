import 'package:flutter/material.dart';

import '../../../../app_localizations.dart';

class RPHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // illustration != null
        //     ? Container(
        //         child: ClipRRect(
        //           child: illustration,
        //           borderRadius: BorderRadius.circular(100),
        //         ),
        //         margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
        //         height: 35,
        //         width: 35,
        //       )
        //     : Container(),
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Text(
            AppLocalizations.of(context).translate("musicHomeRecenltyPlayed"),
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
