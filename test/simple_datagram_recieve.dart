/*
 * Package : Coap
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 13/04/2017
 * Copyright :  S.Hamblett
 */
import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';

Future<void> sleep() =>
    Future<void>.delayed(const Duration(milliseconds: 1), () => '500');


void main() async {
  /// Create and bind to the first(and only!) IPV6 loopback interface
  RawDatagramSocket socket;
  final List<NetworkInterface> interfaces = await NetworkInterface.list(
      includeLoopback: true,
      includeLinkLocal: true,
      type: InternetAddressType.IPv6);
  print(interfaces);
  InternetAddress loopbackAddress;
  for (NetworkInterface interface in interfaces) {
    for (InternetAddress address in interface.addresses) {
      if (address.isLoopback) {
        loopbackAddress = address;
        break;
      }
    }
  }
  print('The selected loopback address is $loopbackAddress');
  socket = await RawDatagramSocket.bind(loopbackAddress, 5683);

  /// Start
  print('Starting recieve test');
  const bool go = true;
  do {
    final Datagram rx = socket.receive();
    if (rx == null) {
      print('Boo no date received at all!');
    } else {
      print('The data is : ${rx.data}');
    }
    await sleep();
  } while (go);
}
