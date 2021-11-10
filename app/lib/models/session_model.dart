part of musicroom.models;

@JsonSerializable(explicitToJson: true, anyMap: true)
class SessionModel {
  String adminUid;
  String masterUid;
  String trackUri;
  int playbackPosition; // Relative player position
  int playbackPositionStartTime; // DateTime in milliseconds
  bool isPaused;
  List<String> members;
  String senderUid;

  SessionModel({
    this.adminUid,
    this.masterUid,
    this.trackUri,
    this.playbackPosition,
    this.playbackPositionStartTime,
    this.isPaused,
    this.members,
    this.senderUid,
  });

  factory SessionModel.fromJson(Map<dynamic, dynamic> json) =>
      _$SessionModelFromJson(json);

  Map<String, dynamic> toJson() {
    var sessionJson = _$SessionModelToJson(this);
    Map<String, dynamic> membersAsKeys = {};
    this.members.forEach((memberId) => membersAsKeys[memberId] = true);
    return {
      ...sessionJson,
      'membersAsKeys': {...membersAsKeys},
    };
  }
}
