import "dart:async";
import "dart:io";
import "dart:typed_data";

import "../../utils/logger.dart";
import "../authentication/auth.dart";
import "message.dart";

class Connection {
  final Socket socket;
  final int id;
  final Function(Connection, Message) onMessageReceived;
  final Function(Connection, String reason) onClientDisconnected;
  final Function(Connection) onClientConnected;

  bool _validate;
  late Timer _timer;
  Connection(
    this.socket,
    this.id,
    this.onMessageReceived,
    this.onClientDisconnected,
    this.onClientConnected,
  ) : _validate = false {
    socket.listen(
      (Uint8List raw) => _readMessage(raw),
      onDone: () {
        if (_validate) {
          onClientDisconnected(this, "Client closed connection");
        }
      },
    );
    _timer = Timer(const Duration(seconds: 3), () {
      socket.destroy();
      onClientDisconnected(this, "Validation timeout");
    });
  }

  void _readMessage(Uint8List data) {
    final type = data[0];
    Message? msg;
    if (type == 1 && !_validate) {
      final str = String.fromCharCodes(data.getRange(1, data.length));
      _timer.cancel();
      if (Authentication().verify(str)) {
        _validate = true;
        onClientConnected(this);
      } else {
        onClientDisconnected(this, "Validation failed");
      }
    } else if (type != 1 && _validate) {
      switch (type) {
        case 0:
          msg = PingMsg();
          break;
        default:
          Logger.error("Message Error");
          return;
      }
      onMessageReceived(this, msg);
    } else {
      Logger.error("Message Error");
    }
  }

  void sendMessage(Message msg) {
    ///TODO: To be implemented
  }

  void disconnect() {
    socket.destroy();
    onClientDisconnected(this, "Server kicked");
  }
}
