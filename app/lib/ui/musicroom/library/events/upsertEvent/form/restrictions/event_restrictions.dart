import 'dart:developer';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';

import '../../../../../../../models/_models.dart';
import './mapScreen/map_screen.dart';

class EventRestrictions extends StatefulWidget {
  final EventSettings currentSettings;
  final Function updateSettings;

  const EventRestrictions(
    this.currentSettings,
    this.updateSettings,
  );

  @override
  _EventRestrictionsState createState() => _EventRestrictionsState();
}

class _EventRestrictionsState extends State<EventRestrictions> {
  EventSettings settings;

  @override
  Widget build(BuildContext context) {
    settings = EventSettings.from(widget.currentSettings);
    settings.voteRestrictions = EventSettingsVoteRestrictions(
      startDate:
          widget.currentSettings?.voteRestrictions?.startDate ?? DateTime.now(),
      endDate: widget.currentSettings?.voteRestrictions?.endDate ??
          DateTime.now().add(new Duration(hours: 2)),
      locationLatLng:
          widget.currentSettings?.voteRestrictions?.locationLatLng ??
              LatLng(48.896682999999996, 2.318387963450124),
      locationName: widget.currentSettings?.voteRestrictions?.locationName ??
          "42, 75017 Paris, France",
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.event),
          title: Text('Time restriction'),
          trailing: Switch(
            value: settings?.isTimeRestrictionEnabled ?? false,
            onChanged: (value) {
              settings.isTimeRestrictionEnabled = value;
              widget.updateSettings(settings);
            },
            activeColor: Theme.of(context).accentColor,
          ),
        ),
        settings?.isTimeRestrictionEnabled == true
            ? ListTile(
                leading: Text(''),
                title: DateTimePicker(
                  type: DateTimePickerType.dateTimeSeparate,
                  dateMask: 'd MMM, yyyy',
                  initialValue:
                      settings.voteRestrictions?.startDate?.toString(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  dateLabelText: 'From',
                  timeLabelText: '',
                  cursorColor: Theme.of(context).accentColor,
                  onChanged: (String val) {
                    settings.voteRestrictions.startDate = DateTime.parse(val);
                    widget.updateSettings(settings);
                  },
                ),
              )
            : Container(),
        settings?.isTimeRestrictionEnabled == true
            ? ListTile(
                leading: Text(''),
                title: DateTimePicker(
                  type: DateTimePickerType.dateTimeSeparate,
                  dateMask: 'd MMM, yyyy',
                  initialValue: settings.voteRestrictions?.endDate?.toString(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  dateLabelText: 'To',
                  timeLabelText: '',
                  onChanged: (String val) {
                    settings.voteRestrictions.endDate = DateTime.parse(val);
                    widget.updateSettings(settings);
                  },
                ),
              )
            : Container(),
        ListTile(
          leading: Icon(Icons.location_pin),
          title: Text('Location restriction'),
          trailing: Switch(
            value: settings?.isLocationRestrictionEnabled ?? false,
            onChanged: (value) {
              settings.isLocationRestrictionEnabled = value;
              widget.updateSettings(settings);
            },
            activeColor: Theme.of(context).accentColor,
          ),
        ),
        settings?.isLocationRestrictionEnabled == true
            ? ListTile(
                leading: Text(''),
                title: settings?.voteRestrictions?.locationLatLng == null
                    ? Text('No location restriction')
                    : Text(
                        settings.voteRestrictions?.locationName ??
                            settings?.voteRestrictions?.locationLatLng
                                ?.toString(),
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MapScreen(
                              widget.currentSettings,
                              widget.updateSettings,
                            ))),
              )
            : Container(),
      ],
    );
  }
}
