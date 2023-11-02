import "sys/authentication/auth.dart";
import "sys/http/http.dart";
import "sys/networking/network.dart";
import "sys/database.dart";
import "utils/logger.dart";

void main(List<String> args) async {
  Logger.initialize();
  
  Logger.error("Database version: ${Database.version}");
  Logger.error("TCP Server version: ${Network.version}");
  Logger.error("HTTP Server version: ${HTTP.version}");

  await Database.initialize(
    host: "localhost",
    port: 5432,
    username: "postgres",
    password: "phapgo123",
  );
  await Database().migrate();
  Authentication.initialize();
  await Network.initialize();
  await HTTP.serve();
}
