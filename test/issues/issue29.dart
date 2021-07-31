import 'dart:async';
import 'package:coap/coap.dart';
import 'config/coap_config.dart';

FutureOr main() async {
  // Create a configuration class. Logging levels can be specified in the
  // configuration file.
  final conf = CoapConfig();

  final uri = Uri(
    scheme: 'coap',
    host: 'coap.me',
    port: conf.defaultPort,
  );

  final client1 = CoapClient(uri, conf);
  final firstPingResponse = await client1.ping(10000);
  client1.close();
  // This works
  print(firstPingResponse);

  final uri1 = Uri(
    scheme: 'coap',
    host: 'coap.me',
    port: conf.defaultPort,
  );

  final client2 = CoapClient(uri1, conf);
  final secondPingResponse = await client2.ping(10000);
  client2.close();

  print(secondPingResponse);
}
