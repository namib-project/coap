/*
 * Package : Coap
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 27/04/2017
 * Copyright :  S.Hamblett
 */

part of coap;

/// Configuration loading class. The config file itself is a YAML
/// file. The configuration items below are marked as optional to allow
/// the config file to contain only those entries that override the defaults.
/// The file can't be empty, so version must as a minimum be present.
class CoapConfig extends config.ConfigurationItem {
  CoapConfig(String filename) : super.fromFile(filename);

  /// The version of the CoAP protocol.
  String version = "RFC7252";

  /// The default CoAP port for normal CoAP communication (not secure).
  @config.optionalConfiguration
  int defaultPort = CoapConstants.defaultPort;

  /// The default CoAP port for secure CoAP communication (coaps).
  @config.optionalConfiguration
  int defaultSecurePort = CoapConstants.defaultSecurePort;

  /// The port which HTTP proxy is on.
  @config.optionalConfiguration
  int httpPort = 8080;

  /// The initial time (ms) for a CoAP message
  @config.optionalConfiguration
  int ackTimeout = CoapConstants.ackTimeout;

  /// The initial timeout is set
  /// to a random number between RESPONSE_TIMEOUT and (RESPONSE_TIMEOUT *
  /// RESPONSE_RANDOM_FACTOR)
  ///
  @config.optionalConfiguration
  double AckRandomFactor = CoapConstants.ackRandomFactor;

  @config.optionalConfiguration
  double AckTimeoutScale = 2.0;

  /// The max time that a message would be retransmitted
  @config.optionalConfiguration
  int MaxRetransmit = CoapConstants.maxRetransmit;

  @config.optionalConfiguration
  int MaxMessageSize = 1024;

  /// The default preferred size of block in blockwise transfer.
  @config.optionalConfiguration
  int DefaultBlockSize = CoapConstants.defaultBlockSize;

  @config.optionalConfiguration
  int blockwiseStatusLifetime = 10 * 60 * 1000; // ms
  @config.optionalConfiguration
  bool useRandomIDStart = true;
  @config.optionalConfiguration
  bool useRandomTokenStart = true;

  @config.optionalConfiguration
  int notificationMaxAge = 128 * 1000; // ms
  @config.optionalConfiguration
  int notificationCheckIntervalTime = 24 * 60 * 60 * 1000; // ms
  @config.optionalConfiguration
  int notificationCheckIntervalCount = 100; // ms
  @config.optionalConfiguration
  int notificationReregistrationBackoff = 2000; // ms

  //TODO string deduplicator = CoAP.Deduplication.DeduplicatorFactory.MarkAndSweepDeduplicator;
  @config.optionalConfiguration
  int cropRotationPeriod = 2000; // ms
  @config.optionalConfiguration
  int exchangeLifetime = 247 * 1000; // ms
  @config.optionalConfiguration
  int markAndSweepInterval = 10 * 1000; // ms
  @config.optionalConfiguration
  int channelReceivePacketSize = 2048;
}