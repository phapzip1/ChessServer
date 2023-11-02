import "dart:convert";

import "package:crypto/crypto.dart";
import "package:dart_jsonwebtoken/dart_jsonwebtoken.dart";
import "package:uuid/uuid.dart";

import "../database.dart";

class Authentication {
  static Authentication? _instance;
  Authentication._internal()
      : _key = SecretKey("hennhauluc4gio"),
        _uuid = Uuid();
  factory Authentication() => _instance!;
  static void initialize() {
    _instance ??= Authentication._internal();
  }

  final JWTKey _key;
  final Uuid _uuid;

  bool verify(String token) {
    try {
      JWT.verify(token, _key);
      return true;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic>? parseToken(String token) {
    final payload = JWT.tryDecode(token)?.payload;
    if (payload != null) {
      return jsonDecode(payload);
    }
    return null;
  }

  Future<String?> login(String username, String password) async {
    final hashed = md5.convert(utf8.encode(password)).toString();
    final res = await Database().query(
      "SELECT * FROM CHESS.USERS WHERE email = @pEmail AND password = @pPassword;",
      {
        "pEmail": username,
        "pPassword": hashed,
      },
    );
    if (res.isNotEmpty) {
      final uid = res[0]["users"]["uid"];
      final jwt = JWT({"uid": uid}, issuer: "Phac");
      return jwt.sign(_key, noIssueAt: true);
    }
    return null;
  }

  Future<bool> register(
    String username,
    String password,
    String email,
    String birthday,
    int gender,
  ) async {
    try {
      final hashed = md5.convert(utf8.encode(password)).toString();
      Database().query("""
      INSERT INTO CHESS.USERS (uid, username, password, avatar, email, gender, birthday, nickname, elo)
      VALUES(@uid, @username, @password, @avatar, @email, @gender, @birthday, @username, @elo)
      """, {
        "uid": _uuid.v4(),
        "username": username,
        "password": hashed,
        "avatar":
            "https://i.etsystatic.com/14951240/r/il/6b7a35/3536263578/il_570xN.3536263578_8ry6.jpg",
        "email": email,
        "gender": gender,
        "birthday": birthday,
        "elo": 666,
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
