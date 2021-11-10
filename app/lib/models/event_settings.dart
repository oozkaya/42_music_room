part of musicroom.models;

@JsonSerializable(explicitToJson: true, anyMap: true)
class EventSettingsVoteRestrictions {
  @TimestampConverter()
  DateTime startDate;
  @TimestampConverter()
  DateTime endDate;
  @LatLngConverter()
  LatLng locationLatLng;
  String locationName;

  EventSettingsVoteRestrictions({
    this.startDate,
    this.endDate,
    this.locationLatLng,
    this.locationName,
  });

  factory EventSettingsVoteRestrictions.fromJson(Map<dynamic, dynamic> json) {
    return _$EventSettingsVoteRestrictionsFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$EventSettingsVoteRestrictionsToJson(this);
  }
}

@JsonSerializable(explicitToJson: true, anyMap: true)
class EventSettings {
  EventSettingsVoteRestrictions voteRestrictions =
      EventSettingsVoteRestrictions();
  bool isTimeRestrictionEnabled = false;
  bool isLocationRestrictionEnabled = false;

  EventSettings({
    this.voteRestrictions,
    this.isTimeRestrictionEnabled,
    this.isLocationRestrictionEnabled,
  });

  factory EventSettings.from(EventSettings settings) {
    return new EventSettings(
      voteRestrictions: EventSettingsVoteRestrictions(
        startDate: settings.voteRestrictions?.startDate,
        endDate: settings.voteRestrictions?.endDate,
        locationLatLng: settings.voteRestrictions?.locationLatLng,
        locationName: settings.voteRestrictions?.locationName,
      ),
      isTimeRestrictionEnabled: settings?.isTimeRestrictionEnabled ?? false,
      isLocationRestrictionEnabled:
          settings?.isLocationRestrictionEnabled ?? false,
    );
  }

  factory EventSettings.fromJson(Map<dynamic, dynamic> json) =>
      _$EventSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$EventSettingsToJson(this);
}
