class User {
  final String uid;
  final String username;
  final String nickname;
  final String email;
  final int gender;
  final String avatar;
  final DateTime birthday;
  final int elo;
  final DateTime createdTime;

  User({
    required this.uid,
    required this.username,
    required this.nickname,
    required this.email,
    required this.gender,
    required this.avatar,
    required this.birthday,
    required this.elo,
    required this.createdTime,
  });

  User copyWith({
    String? nickname,
    int? gender,
    int? elo,
    String? avatar,
  }) =>
      User(
        uid: uid,
        username: username,
        nickname: nickname ?? this.nickname,
        email: email,
        gender: gender ?? this.gender,
        avatar: avatar ?? this.avatar,
        birthday: birthday,
        elo: elo ?? this.elo,
        createdTime: createdTime,
      );
}
