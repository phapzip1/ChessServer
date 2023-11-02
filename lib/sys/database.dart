import "package:chessserver/utils/logger.dart";
import "package:postgres/postgres.dart";

import "../models/user.dart";
import "../utils/exception.dart";

class Database {
  static const version = "1.0.0";
  static Database? _instance;
  factory Database() {
    if (_instance == null) throw SingletonNotInitializedException();
    return _instance!;
  }
  static Future<void> initialize({
    required String host,
    required int port,
    required String username,
    required String password,
  }) async {
    if (_instance == null) {
      final conn = PostgreSQLConnection(host, port, "postgres",
          username: username, password: password);
      await conn.open();
      _instance = Database._internal(conn);

      Logger.info("Database connection established!☕");
    }
  }

  Database._internal(PostgreSQLConnection connection) : _conn = connection;

  static Future<void> dispose() async => await _instance?._dispose();

  // members
  final PostgreSQLConnection _conn;

  Future<void> migrate() async {
    await _conn.query("CREATE SCHEMA IF NOT EXISTS CHESS;");
    await _conn.query(r'''
    CREATE TABLE IF NOT EXISTS CHESS.USERS(
      uid VARCHAR(100) PRIMARY KEY,
      username VARCHAR(50) UNIQUE NOT NULL,
      password VARCHAR(80) NOT NULL,
      avatar VARCHAR(255) NULL,
      email VARCHAR(50) UNIQUE,
      gender SMALLINT UNIQUE,
      birthday DATE,
      nickname VARCHAR(50),
      elo SMALLINT CHECK(elo >= 0),
      createdtime TIMESTAMP DEFAULT NOW()
    );
    ''');
    Logger.warn("Migration done!🔥");
  }

  Future<List<Map<String, dynamic>>> query(
    String queryString, [
    Map<String, dynamic>? params,
  ]) =>
      _conn.mappedResultsQuery(queryString, substitutionValues: params);

  Future<User?> getUser(String uid) async {
    final res = await _conn.mappedResultsQuery(
      "SELECT * FROM CHESS.USERS WHERE uid = @uid",
      substitutionValues: {
        "uid": uid,
      },
    );

    if (res.isNotEmpty) {
      final data = res[0]["users"]!;
      return User(
        uid: uid,
        username: data["username"],
        nickname: data["nickname"],
        email: data["email"],
        gender: data["gender"],
        avatar: data["avatar"],
        birthday: data["birthday"],
        elo: data["elo"],
        createdTime: data["createdtime"],
      );
    }

    return null;
  }

  Future<bool> updateUser(User user) async {
    try {
      await _conn.mappedResultsQuery(
        """
      UPDATE USERS
      SET nickname = @nickname, gender = @gender, avatar = @avatar, elo = @elo
      WHERE uid = @uid
      """,
        substitutionValues: {
          "uid": user.uid,
          "nickname": user.nickname,
          "gender": user.gender,
          "avatar": user.avatar,
          "elo": user.elo,
        },
      );
      return true;
    } catch (e) {
      Logger.error(e.toString());
      return false;
    }
  }

  Future<void> _dispose() async {
    await _conn.close();
    Logger.info("Database connection closed!");
  }
}
