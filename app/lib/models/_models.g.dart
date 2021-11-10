// GENERATED CODE - DO NOT MODIFY BY HAND

part of musicroom.models;

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventUsersRights _$EventUsersRightsFromJson(Map json) {
  return EventUsersRights(
    read: json['read'] as bool,
    edit: json['edit'] as bool,
    vote: json['vote'] as bool,
  );
}

Map<String, dynamic> _$EventUsersRightsToJson(EventUsersRights instance) =>
    <String, dynamic>{
      'read': instance.read,
      'edit': instance.edit,
      'vote': instance.vote,
    };

EventModel _$EventModelFromJson(Map json) {
  return EventModel(
    id: json['id'] as String,
    adminUserId: json['adminUserId'] as String,
    adminUsername: json['adminUsername'] as String,
    isPublic: json['isPublic'] as bool,
    name: json['name'] as String,
    nameLower: json['nameLower'] as String,
    tracks: EventModel._tracksFromJson(json['tracks'] as List),
    playbackPosition: json['playbackPosition'] as int,
    playbackPositionStartTime: json['playbackPositionStartTime'] as int,
    isPaused: json['isPaused'] as bool,
    usersRights: (json['usersRights'] as Map)?.map(
      (k, e) => MapEntry(
          k as String, e == null ? null : EventUsersRights.fromJson(e as Map)),
    ),
    followers: EventModel._followersFromJson(json['followers']),
    membersCounter: json['membersCounter'] as int,
    settings: json['settings'] == null
        ? null
        : EventSettings.fromJson(json['settings'] as Map),
    keywords: (json['keywords'] as List)?.map((e) => e as String)?.toList(),
  );
}

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'adminUserId': instance.adminUserId,
      'adminUsername': instance.adminUsername,
      'isPublic': instance.isPublic,
      'name': instance.name,
      'nameLower': instance.nameLower,
      'settings': instance.settings?.toJson(),
      'tracks': instance.tracks?.map((e) => e?.toJson())?.toList(),
      'usersRights':
          instance.usersRights?.map((k, e) => MapEntry(k, e?.toJson())),
      'followers': instance.followers,
      'playbackPosition': instance.playbackPosition,
      'playbackPositionStartTime': instance.playbackPositionStartTime,
      'isPaused': instance.isPaused,
      'membersCounter': instance.membersCounter,
      'keywords': instance.keywords,
    };

EventSettingsVoteRestrictions _$EventSettingsVoteRestrictionsFromJson(
    Map json) {
  return EventSettingsVoteRestrictions(
    startDate: const TimestampConverter().fromJson(json['startDate']),
    endDate: const TimestampConverter().fromJson(json['endDate']),
    locationLatLng:
        const LatLngConverter().fromJson(json['locationLatLng'] as String),
    locationName: json['locationName'] as String,
  );
}

Map<String, dynamic> _$EventSettingsVoteRestrictionsToJson(
        EventSettingsVoteRestrictions instance) =>
    <String, dynamic>{
      'startDate': const TimestampConverter().toJson(instance.startDate),
      'endDate': const TimestampConverter().toJson(instance.endDate),
      'locationLatLng': const LatLngConverter().toJson(instance.locationLatLng),
      'locationName': instance.locationName,
    };

EventSettings _$EventSettingsFromJson(Map json) {
  return EventSettings(
    voteRestrictions: json['voteRestrictions'] == null
        ? null
        : EventSettingsVoteRestrictions.fromJson(
            json['voteRestrictions'] as Map),
    isTimeRestrictionEnabled: json['isTimeRestrictionEnabled'] as bool,
    isLocationRestrictionEnabled: json['isLocationRestrictionEnabled'] as bool,
  );
}

Map<String, dynamic> _$EventSettingsToJson(EventSettings instance) =>
    <String, dynamic>{
      'voteRestrictions': instance.voteRestrictions?.toJson(),
      'isTimeRestrictionEnabled': instance.isTimeRestrictionEnabled,
      'isLocationRestrictionEnabled': instance.isLocationRestrictionEnabled,
    };

EventTrack _$EventTrackFromJson(Map json) {
  return EventTrack(
    json['track'] == null
        ? null
        : Track.fromJson((json['track'] as Map)?.map(
            (k, e) => MapEntry(k as String, e),
          )),
  )
    ..id = json['id'] as String
    ..upVotesUids =
        (json['upVotesUids'] as List)?.map((e) => e as String)?.toList();
}

Map<String, dynamic> _$EventTrackToJson(EventTrack instance) =>
    <String, dynamic>{
      'track': instance.track?.toJson(),
      'id': instance.id,
      'upVotesUids': instance.upVotesUids,
    };

CollabUserRights _$CollabUserRightsFromJson(Map<String, dynamic> json) {
  return CollabUserRights(
    read: json['read'] as bool,
    write: json['write'] as bool,
  );
}

Map<String, dynamic> _$CollabUserRightsToJson(CollabUserRights instance) =>
    <String, dynamic>{
      'read': instance.read,
      'write': instance.write,
    };

CollabRights _$CollabRightsFromJson(Map<String, dynamic> json) {
  return CollabRights(
    isVisibilityPublic: json['isVisibilityPublic'] as bool,
    isEditionPublic: json['isEditionPublic'] as bool,
    usersRights: (json['usersRights'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(
          k,
          e == null
              ? null
              : CollabUserRights.fromJson(e as Map<String, dynamic>)),
    ),
  );
}

Map<String, dynamic> _$CollabRightsToJson(CollabRights instance) =>
    <String, dynamic>{
      'isVisibilityPublic': instance.isVisibilityPublic,
      'isEditionPublic': instance.isEditionPublic,
      'usersRights':
          instance.usersRights?.map((k, e) => MapEntry(k, e?.toJson())),
    };

Collab _$CollabFromJson(Map<String, dynamic> json) {
  return Collab(
    id: json['id'] as String,
    adminUserId: json['adminUserId'] as String,
    adminUsername: json['adminUsername'] as String,
    name: json['name'] as String,
    nameLower: json['nameLower'] as String,
    tracks: Collab._tracksFromJson(json['tracks'] as List),
    rights: json['rights'] == null
        ? null
        : CollabRights.fromJson(json['rights'] as Map<String, dynamic>),
    likes: Collab._likesFromJson(json['likes'] as List),
    createdAt: const TimestampConverter().fromJson(json['createdAt']),
    updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  );
}

Map<String, dynamic> _$CollabToJson(Collab instance) => <String, dynamic>{
      'id': instance.id,
      'adminUserId': instance.adminUserId,
      'adminUsername': instance.adminUsername,
      'tracks': instance.tracks?.map((e) => e?.toJson())?.toList(),
      'rights': Collab.toNull(instance.rights),
      'likes': instance.likes,
      'name': instance.name,
      'nameLower': instance.nameLower,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

UserModel _$UserModelFromJson(Map json) {
  return UserModel(
    uid: json['uid'] as String,
    email: json['email'] as String,
    nickName: json['nickName'] as String,
    favoriteMusicCategory: json['favoriteMusicCategory'] as String,
    friendsIds: UserModel._friendsFromJson(json['friends'] as Map),
    event: json['event'] as String,
    session: json['session'] as String,
  );
}

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'nickName': instance.nickName,
      'favoriteMusicCategory': instance.favoriteMusicCategory,
      'event': instance.event,
      'session': instance.session,
      'friends': UserModel._friendsToJson(instance.friendsIds),
    };

SessionModel _$SessionModelFromJson(Map json) {
  return SessionModel(
    adminUid: json['adminUid'] as String,
    masterUid: json['masterUid'] as String,
    trackUri: json['trackUri'] as String,
    playbackPosition: json['playbackPosition'] as int,
    playbackPositionStartTime: json['playbackPositionStartTime'] as int,
    isPaused: json['isPaused'] as bool,
    members: (json['members'] as List)?.map((e) => e as String)?.toList(),
    senderUid: json['senderUid'] as String,
  );
}

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'adminUid': instance.adminUid,
      'masterUid': instance.masterUid,
      'trackUri': instance.trackUri,
      'playbackPosition': instance.playbackPosition,
      'playbackPositionStartTime': instance.playbackPositionStartTime,
      'isPaused': instance.isPaused,
      'members': instance.members,
      'senderUid': instance.senderUid,
    };
