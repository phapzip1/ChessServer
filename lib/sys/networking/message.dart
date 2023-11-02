import "dart:typed_data";

abstract class Message {
  Uint8List toBytes();
}

class PingMsg implements Message {
  @override
  Uint8List toBytes() => Uint8List.fromList([0]);
}

class ValidateMsg implements Message {
  final String jwt;

  ValidateMsg(this.jwt);

  @override
  Uint8List toBytes() => Uint8List.fromList([1, jwt.length, ...jwt.codeUnits]);
}
