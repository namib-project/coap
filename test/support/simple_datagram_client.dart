import 'dart:async';
import 'dart:io';
import 'package:hex/hex.dart';

void main() async {
  /// Create and bind to the first(and only!) IPV4 loopback interface
  final List<NetworkInterface> interfaces = await NetworkInterface.list(
      includeLoopback: false,
      includeLinkLocal: false,
      type: InternetAddressType.IPv4);
  print(interfaces);
  InternetAddress ipAddress;
  for (NetworkInterface interface in interfaces) {
    for (InternetAddress address in interface.addresses) {
      if (!address.isLoopback) {
        ipAddress = address;
        break;
      }
    }
  }

  print('The selected address is $ipAddress');

  await RawDatagramSocket.bind(ipAddress, 5683)
      .then((RawDatagramSocket socket) {
    print('Datagram socket ready to receive');
    print('Waiting on ${socket.address.address}:${socket.port} .....');
    socket.listen((RawSocketEvent e) {
      switch (e) {
        case RawSocketEvent.write:
          print('Write recieved - $e');
          final Datagram d = socket.receive();
          if (d == null) {
            break;
          }
          print('Received: ${HEX.encode(d.data)}');
          break;
        case RawSocketEvent.read:
          print('Read recieved - $e');
          final Datagram d = socket.receive();
          if (d == null) {
            break;
          }
          print('Received: ${HEX.encode(d.data)}');
          break;
        case RawSocketEvent.closed:
          print('Closed received - $e');
          break;
        default:
          print('Default');
      }
    });
  });

  await Future<void>.delayed(Duration(milliseconds: 400000));
}
