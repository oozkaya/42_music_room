import 'package:flutter/material.dart';

import '../../../../app_localizations.dart';
import '../../../../constants/spotify_color_scheme.dart';

class SearchBar extends StatefulWidget {
  final String searchQuery;
  final Function onSubmitted;
  final bool hideBorder;

  SearchBar({
    this.searchQuery,
    this.onSubmitted,
    this.hideBorder,
  });

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  FocusNode _focus = new FocusNode();
  bool _hasFocus = false;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = !_hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller =
        TextEditingController(text: widget.searchQuery);
    int offset = widget.searchQuery?.length ?? 0;
    controller.selection =
        TextSelection(baseOffset: offset, extentOffset: offset);

    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: TextField(
        controller: controller,
        focusNode: _focus,
        autofocus: false,
        cursorColor: Theme.of(context).colorScheme.green,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).translate("musicSearchTitle"),
          prefixIcon: _hasFocus ? null : Icon(Icons.search),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
          hintStyle: TextStyle(
            fontSize: Theme.of(context).textTheme.headline5.fontSize,
            fontWeight: FontWeight.w600,
          ),
          fillColor: _hasFocus
              ? Theme.of(context).colorScheme.mediumGray
              : Theme.of(context).colorScheme.primaryVariant,
          filled: true,
          border: widget.hideBorder != true
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.mediumGray))
              : null,
          focusedBorder: InputBorder.none,
        ),
        onSubmitted: widget.onSubmitted != null ? widget.onSubmitted : null,
      ),
    );
  }
}
