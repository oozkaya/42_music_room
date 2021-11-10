part of musicroom.models;

@JsonSerializable(explicitToJson: true, anyMap: true)
class UserModel {
  String uid;
  String email;
  String nickName;
  String favoriteMusicCategory;
  String event;
  String session;
  @JsonKey(name: "friends", fromJson: _friendsFromJson, toJson: _friendsToJson)
  List<String> friendsIds;

  UserModel({
    this.uid,
    this.email,
    this.nickName,
    this.favoriteMusicCategory,
    this.friendsIds,
    this.event,
    this.session,
  });

  static List<String> _friendsFromJson(Map<dynamic, dynamic> friendsJson) {
    List<String> _friends = [];
    friendsJson?.forEach((k, v) => _friends.add(v as String));
    return _friends;
  }

  static Map<dynamic, dynamic> _friendsToJson(List<String> friendsIds) {
    if (friendsIds == null) return {};
    return Map.fromIterable(friendsIds,
        key: (friendId) => friendId, value: (friendId) => friendId);
  }

  factory UserModel.fromJson(Map<dynamic, dynamic> json, String documentId) {
    json['uid'] = documentId;
    return _$UserModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.from(UserModel user) {
    return new UserModel(
      uid: user?.uid,
      email: user?.email,
      nickName: user?.nickName,
      favoriteMusicCategory: user?.favoriteMusicCategory,
      friendsIds: user?.friendsIds,
      event: user?.event,
      session: user?.session,
    );
  }
}
