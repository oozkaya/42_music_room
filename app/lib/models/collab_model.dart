part of musicroom.models;

@JsonSerializable(explicitToJson: true)
class CollabUserRights {
  bool read = true;
  bool write = false;

  CollabUserRights({this.read, this.write});

  factory CollabUserRights.fromCollabUserRights(CollabUserRights userRights) {
    return CollabUserRights(
      read: userRights.read,
      write: userRights.write,
    );
  }

  factory CollabUserRights.fromJson(Map<String, dynamic> json) =>
      _$CollabUserRightsFromJson(json);

  Map<String, dynamic> toJson() => _$CollabUserRightsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CollabRights {
  bool isVisibilityPublic = true;
  bool isEditionPublic = true;
  Map<String, CollabUserRights> usersRights = {};

  CollabRights({
    this.isVisibilityPublic,
    this.isEditionPublic,
    this.usersRights,
  });

  Map<String, List<dynamic>> usersRightsToListsForIndexedSearch(
      String adminUserId) {
    var read = [adminUserId];
    var write = [adminUserId];
    this.usersRights?.forEach((userId, rights) {
      if (rights?.read == true) read.add(userId);
      if (rights?.write == true) write.add(userId);
    });
    return {
      'restrictedVisibility': read,
      'restrictedEdition': write,
    };
  }

  factory CollabRights.fromJson(Map<String, dynamic> json) {
    var collabRights = _$CollabRightsFromJson(json);
    if (collabRights.usersRights == null) collabRights.usersRights = {};
    return collabRights;
  }

  Map<String, dynamic> toJson(String adminUserId) {
    var json = _$CollabRightsToJson(this);
    var rights = usersRightsToListsForIndexedSearch(adminUserId);
    return {...json, ...rights};
  }
}

@JsonSerializable(explicitToJson: true)
class Collab {
  final String id;
  final String adminUserId;
  final String adminUsername;
  @JsonKey(fromJson: _tracksFromJson)
  final List<Track> tracks;
  @JsonKey(toJson: toNull)
  final CollabRights rights;
  @JsonKey(fromJson: _likesFromJson)
  final List<String> likes;
  String name;
  String nameLower;
  @TimestampConverter()
  DateTime createdAt;
  @TimestampConverter()
  DateTime updatedAt;

  Collab({
    this.id,
    this.adminUserId,
    this.adminUsername,
    this.name,
    this.nameLower,
    this.tracks,
    this.rights,
    this.likes,
    this.createdAt,
    this.updatedAt,
  });

  static toNull(_) => null;

  static List<Track> _tracksFromJson(List<dynamic> tracksJson) {
    return tracksJson
            ?.map((e) =>
                e == null ? null : Track.fromJson(e as Map<String, dynamic>))
            ?.toList() ??
        [];
  }

  static List<String> _likesFromJson(List<dynamic> likesJson) {
    return likesJson?.map((e) => e as String)?.toList() ?? [];
  }

  factory Collab.fromJson(Map<String, dynamic> json, String documentId) {
    json['id'] = documentId;
    return _$CollabFromJson(json);
  }

  Map<String, dynamic> toJson() {
    var collab = _$CollabToJson(this);
    collab['rights'] = this.rights?.toJson(this.adminUserId) ??
        {
          'restrictedVisibility': [this.adminUserId],
          'restrictedEdition': [this.adminUserId],
        };
    return collab;
  }
}
