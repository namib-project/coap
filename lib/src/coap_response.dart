/*
 * Package : Coap
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 31/10/2017
 * Copyright :  S.Hamblett
 */

part of coap;

/// Represents a CoAP response to a CoAP request.
/// A response is either a piggy-backed response with type ACK
/// or a separate response with type CON or NON.
class CoapResponse extends CoapMessage {
  /// Initializes a response message.
  CoapResponse(int statusCode)
      : super.withCode(CoapMessageType.unknown, statusCode) {
    _statusCode = code;
  }

  /// The response status code.
  int _statusCode;

  int get statusCode => _statusCode;

  /// The Round-Trip Time of this response.
  double rtt;

  /// A value indicating whether this response is the last response of an exchange.
  bool last = true;

  /// Response text
  String get responseText => payloadString;

  /// Creates a response to the specified request with the specified response code.
  /// The destination endpoint of the response is the source endpoint of the request.
  /// The response has the same token as the request.
  /// Type and ID are usually set automatically by the ReliabilityLayer>.
  static CoapResponse createResponse(CoapRequest request, int statusCode) {
    final CoapResponse response = new CoapResponse(statusCode);
    response.destination = request.source;
    response.token = request.token;
    return response;
  }
}