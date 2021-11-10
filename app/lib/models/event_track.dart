part of musicroom.models;

@JsonSerializable(explicitToJson: true, anyMap: true)
class EventTrack {
  Track track;
  String id;
  List<String> upVotesUids;

  EventTrack(
    this.track, {
    bool newTrack,
  }) {
    if (newTrack == true) {
      this.id = Uuid().v4();
    }
  }

  factory EventTrack.fromJson(Map<dynamic, dynamic> json) {
    var eventTrack = _$EventTrackFromJson(json);
    if (eventTrack.upVotesUids == null) eventTrack.upVotesUids = [];
    return eventTrack;
  }

  Map<String, dynamic> toJson() => _$EventTrackToJson(this);
}
