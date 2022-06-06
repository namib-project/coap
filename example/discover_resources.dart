/*
 * Package : Coap
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 06/06/2018
 * Copyright :  S.Hamblett
 *
 * A simple discover request using .well-known/core to discover a servers resource list
 */

import 'dart:async';
import 'package:coap/coap.dart';
import 'config/coap_config.dart';

FutureOr<void> main(List<String> args) async {
  final conf = CoapConfig();
  final uri = Uri.parse("coap://coap.me");
  final client = CoapClient(conf);

  try {
    print('Sending get /discover/.well-known/core to ${uri.host}');
    final links = await client.discover(uri);

    print('Discovered resources:');
    links?.forEach(print);
  } catch (e) {
    print('CoAP encountered an exception: $e');
  }

  client.close();
}
