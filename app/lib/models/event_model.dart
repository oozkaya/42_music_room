part of musicroom.models;

@JsonSerializable(explicitToJson: true, anyMap: true)
class EventUsersRights {
  bool read = true;
  bool edit = false;
  bool vote = false;

  EventUsersRights({this.read, this.edit, this.vote});

  factory EventUsersRights.fromCollabUserRights(EventUsersRights userRights) {
    return EventUsersRights(
      read: userRights.read,
      edit: userRights.edit,
      vote: userRights.vote,
    );
  }

  factory EventUsersRights.fromJson(Map<dynamic, dynamic> json) =>
      _$EventUsersRightsFromJson(json);

  Map<String, dynamic> toJson() => _$EventUsersRightsToJson(this);
}

@JsonSerializable(explicitToJson: true, anyMap: true)
class EventModel {
  final String id;
  final String adminUserId;
  final String adminUsername;
  bool isPublic;
  String name;
  String nameLower;
  EventSettings settings;
  @JsonKey(fromJson: _tracksFromJson)
  List<EventTrack> tracks;
  Map<String, EventUsersRights> usersRights;
  @JsonKey(fromJson: _followersFromJson)
  List<String> followers;
  final int playbackPosition; // Relative player position
  final int playbackPositionStartTime; // DateTime in milliseconds
  final bool isPaused;
  final int membersCounter;
  List<String> keywords;

  EventModel({
    this.id,
    this.adminUserId,
    this.adminUsername,
    this.isPublic,
    this.name,
    this.nameLower,
    this.tracks,
    this.playbackPosition,
    this.playbackPositionStartTime,
    this.isPaused,
    this.usersRights,
    this.followers,
    this.membersCounter,
    this.settings,
    this.keywords,
  });

  static List<EventTrack> _tracksFromJson(List<dynamic> tracksJson) {
    return tracksJson
            ?.map((e) => e == null
                ? null
                : EventTrack.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [];
  }

  static List<String> _followersFromJson(dynamic followersJson) {
    if (followersJson == null) return [];
    if (followersJson is Map) {
      List<String> followers = [];
      followersJson.forEach((k, v) => followers.add(v));
      return followers;
    }
    return (followersJson as List)?.map((e) => e as String)?.toList();
  }

  factory EventModel.fromJson(Map<dynamic, dynamic> json, String documentId) {
    json['id'] = documentId;
    return _$EventModelFromJson(json);
  }

  Map<String, List<dynamic>> usersRightsToListsForIndexedSearch() {
    var read = [this.adminUserId];
    var edit = [this.adminUserId];
    var vote = [this.adminUserId];
    this.usersRights?.forEach((userId, rights) {
      if (rights?.read == true) read.add(userId);
      if (rights?.vote == true) vote.add(userId);
      if (rights?.edit == true) edit.add(userId);
    });
    return {
      'restrictedVisibility': read,
      'restrictedVote': vote,
      'restrictedEdition': edit,
    };
  }

  Map<String, dynamic> toJson() {
    var json = _$EventModelToJson(this);
    var rights = usersRightsToListsForIndexedSearch();
    return {...json, ...rights};
  }
}
