/*
 * Package : Coap
 * Author : Jan Romann <jan.romann@uni-bremen.de>
 * Date   : 02/15/2022
 * Copyright :  Jan Romann
 */

import '../coap_response.dart';
import 'exchange.dart';

class CoapMulticastExchange extends CoapExchange {
  CoapMulticastExchange(
    super.request,
    super.origin,
    super.endpoint, {
    required super.namespace,
  });

  final List<CoapResponse> responses = [];

  // ignore: prefer_expression_function_bodies
  bool alreadyReceived(final CoapResponse response) {
    final filteredResponses = responses.where(
      (final element) => element.source == response.source,
    );

    return filteredResponses.isNotEmpty;
  }
}
