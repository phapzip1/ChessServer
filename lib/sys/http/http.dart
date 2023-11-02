import "dart:async";
import "dart:convert";

import "package:chessserver/sys/database.dart";
import "package:dart_jsonwebtoken/dart_jsonwebtoken.dart";
import "package:shelf_router/shelf_router.dart";
import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart" as io;

import "../../sys/authentication/auth.dart";
import "../../utils/logger.dart";

class HTTP {
  static const version = "1.0.0";

  /// Http entry point
  static Future<void> serve() async {
    final app = Router();
    app.get("/", (Request req) {
      return Response.ok(jsonEncode({
        "HealthCheck": "OK",
      }));
    });

    app.post("/login", (Request req) async {
      try {
        final body =
            await req.readAsString().then((value) => jsonDecode(value));
        final username = body["username"];
        final password = body["password"];
        final token = await Authentication().login(username, password);
        if (token != null) {
          return Response.ok(jsonEncode({
            "status": "successful",
            "token": token,
          }));
        } else {
          return Response.ok(jsonEncode({
            "status": "error",
            "msg": "wrong username or password",
          }));
        }
      } catch (e) {
        return Response.badRequest();
      }
    });

    app.put(
      "/own",
      Pipeline().addMiddleware(_auth).addHandler((Request req) async {
        final uid = req.headers["uid"]!;
        final user = await Database().getUser(uid);
        final info =
            await req.readAsString().then((value) => jsonDecode(value));
        if (user != null) {
          final updatedUser = user.copyWith(
            nickname: info["nickname"],
            elo: info["elo"],
            avatar: info["avatar"],
            gender: info["gender"],
          );

          final res = await Database().updateUser(updatedUser);
          return Response.ok(jsonEncode({
            "status": res ? "successful" : "error",
            "message": res ? null : "user not found",
          }));
        }
        return Response.ok(jsonEncode({
          "status": "error",
          "message": "user not found",
        }));
      }),
    );

    app.post("/register", (Request req) async {
      try {
        final body =
            await req.readAsString().then((value) => jsonDecode(value));
        final username = body["username"];
        final password = body["password"];
        final email = body["email"];
        final birthday = body["birthday"];
        final gender = body["gender"];
        final res = await Authentication()
            .register(username, password, email, birthday, gender);
        if (res) {
          return Response.ok(jsonEncode({
            "status": "successful",
          }));
        } else {
          return Response.ok(jsonEncode({
            "status": "error",
          }));
        }
      } catch (e) {
        return Response.badRequest();
      }
    });

    app.get("/user/<uid>", (Request req, String uid) async {
      final user = await Database().getUser(uid);
      if (user != null) {
        final birthday = user.birthday.toIso8601String();
        final createdTime = user.createdTime.toIso8601String();

        return Response.ok(jsonEncode({
          "status": "successful",
          "user": {
            "uid": user.uid,
            "username": user.username,
            "nickname": user.nickname,
            "email": user.email,
            "gender": user.gender,
            "avatar": user.avatar,
            "birthday": birthday,
            "elo": user.elo,
            "createdtime": createdTime,
          },
        }));
      }
      return Response.ok(jsonEncode({
        "status": "error",
        "message": "user not found",
      }));
    });

    app.get(
      "/own",
      Pipeline().addMiddleware(_auth).addHandler((Request req) async {
        final uid = req.headers["uid"]!;
        final user = await Database().getUser(uid);
        if (user != null) {
          final birthday = user.birthday.toIso8601String();
          final createdTime = user.createdTime.toIso8601String();

          return Response.ok(jsonEncode({
            "status": "successful",
            "user": {
              "uid": user.uid,
              "username": user.username,
              "nickname": user.nickname,
              "email": user.email,
              "gender": user.gender,
              "avatar": user.avatar,
              "birthday": birthday,
              "elo": user.elo,
              "createdtime": createdTime,
            },
          }));
        }
        return Response.ok(jsonEncode({
          "status": "error",
          "message": "user not found",
        }));
      }),
    );

    await io.serve(app, "0.0.0.0", 2003);
    Logger.info("Http Server started at 2003!🚀");
  }

  // middlewares
  static FutureOr<Response> Function(Request request) _auth(
          FutureOr<Response> Function(Request request) innerHandler) =>
      (Request req) async {
        final token = req.headers["Authorization"]?.replaceAll('Bearer ', '');
        if (token != null) {
          final payload = JWT.tryDecode(token)!.payload;
          final uid = payload["uid"] as String?;
          if (uid == null) {
            return Response.unauthorized({
              "Invalid or empty token",
            });
          }
          final updatedReq = req.change(headers: {
            "uid": uid,
          });
          return await innerHandler(updatedReq);
        } else {
          return Response.unauthorized({
            "Invalid or empty token",
          });
        }
      };
}
