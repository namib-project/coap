// ignore_for_file: avoid_print

/*
 * Package : Coap
 * Author : J. Romann <jan.romann@uni-bremen.de>
 * Date   : 10/15/2022
 * Copyright :  J. Romann
 *
 * CoAP Server example
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:coap/coap.dart';

FutureOr<void> main() async {
  final server = await CoapServer.bind(
    InternetAddress.anyIPv4,
    CoapUriScheme.coap,
  );
  server.listen(
    (final request) async {
      print('Received the following request: $request\n');
      print('Sending response...\n');
      server
        ..reply(request,
            payload: utf8.encode('Hello World'), responseCode: CoapCode.content)
        ..close();
    },
    onDone: () => print('Done!'),
  );
}
