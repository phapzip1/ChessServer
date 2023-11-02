import "dart:async";
import "dart:io";


import "../../sys/networking/connection.dart";
import '../../utils/logger.dart';
import "message.dart";

class Network {
  static const version = "1.0.0";
  Network._internal(int port)
      : _port = port,
        _id = 0,
        _pool = [],
        _temp = [];

  static Network? _instance;
  factory Network() => _instance!;
  static Future<void> initialize([int port = 2002]) async {
    if (_instance == null) {
      _instance = Network._internal(port);
      await _instance?._start();
    }
  }

  // members
  // late ServerSocket _server;
  final int _port;
  final List<Connection> _pool;
  final List<Connection> _temp;
  int _id;


  Future<void> _start() async {
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, _port);
    server.listen(_dispatcher);
    Logger.info("TCP Server started at $_port!❤️");
  }

  void _dispatcher(Socket socket) {
    final connection = Connection(
      socket,
      _id++,
      _onMessage,
      _onClientDisconnected,
      _onClientConnected
    );

    _temp.add(connection);
  }

  void _onClientConnected(Connection conn) {
    _pool.add(conn);
    _temp.remove(conn);
    Logger.info("Connection [${conn.id}] approved!");
  }

  void _onMessage(Connection con, Message msg) {
    if (msg is PingMsg) {

    }
  }

  void _onClientDisconnected(Connection con, String reason) {
    Logger.info("Client[${con.id}] disconnected: $reason");
    _temp.remove(con);
  }

  void messageClient() {
    
  }

  void messageToAll() {

  }
}
