// Copyright (c) 2023, the coap project authors.
//
// SPDX-License-Identifier: MIT

import 'dart:io';

import 'integer_option.dart';
import 'option.dart';
import 'string_option.dart';

/// Enumeration representing the standardized CoAP URI schemes.
enum CoapUriScheme {
  coap('coap', 5683),
  coaps('coaps', 5684),
  coapTcp('coap+tcp', 5683),
  coapsTcp('coaps+tcp', 5684),
  coapWs('coap+ws', 80),
  coapsWs('coaps+ws', 443),
  ;

  /// Constructs a new [CoapUriScheme] enum value.
  const CoapUriScheme(this.uriScheme, this.defaultPort);

  /// The URI scheme corresponding with this [CoapUriScheme] value.
  final String uriScheme;

  /// The default port number corresponding with this [CoapUriScheme] value.
  final int defaultPort;

  static final _registry = Map.fromEntries(
    values.map((final value) => MapEntry(value.uriScheme, value)),
  );

  /// Parses a [uriScheme] and returns the corresponding [CoapUriScheme] enum
  /// value.
  ///
  /// If the [uriScheme] is unknown or [Null], a [FormatException] is thrown.
  static CoapUriScheme parse(final String? uriScheme) {
    final parsedScheme = _registry[uriScheme];

    if (parsedScheme == null) {
      throw FormatException(
        'Provided request URI scheme $uriScheme is not allowed.',
      );
    }

    return parsedScheme;
  }

  static const _emptyPort = 0;

  /// Returns a [List] of ports that represent the default port for this
  /// [CoapUriScheme].
  ///
  /// 0 is included in this list since the CoAP URI schemes are not supported
  /// by the [Uri] class.
  /// Therefore, a missing port leads to a return value of 0 for the related URI
  /// schemes.
  List<int> get _defaultPorts => [_emptyPort, defaultPort];

  /// Determines if the given [port] is the default for the given CoAP URI
  /// [scheme].
  ///
  /// If the [scheme] is unknown or [Null], this method will throw a
  /// [FormatException].
  static bool usesDefaultPort(final String? scheme, final int port) {
    final defaultPorts = CoapUriScheme.parse(scheme)._defaultPorts;

    return defaultPorts.contains(port);
  }
}

/// Converts a list of [Option]s to a [Uri] of a provided [scheme] as specified
/// in [RFC 7252, section 6.5].
///
/// If no [UriHostOption] is included in the [Option]s, the [destinationAddress]
/// will be used for the host component.
///
/// [RFC 7252, section 6.5]: https://www.rfc-editor.org/rfc/rfc7252.html#section-6.5
Uri optionsToUri(
  final List<Option<Object?>> options, {
  final String? scheme,
  final InternetAddress? destinationAddress,
}) {
  var host = destinationAddress?.address;
  int? port;
  var path = '';
  var query = '';

  for (final option in options) {
    if (option is UriHostOption) {
      host = option.value;
      continue;
    }

    if (option is UriPortOption) {
      final optionValue = option.value;

      if (!CoapUriScheme.usesDefaultPort(scheme, optionValue)) {
        port = optionValue;
      }

      continue;
    }

    if (option is PathOption) {
      // TODO(JKRhb): Refactor?
      final pathSegment = option.value.replaceAll('/', '%2F');
      path = '$path/$pathSegment';
      continue;
    }

    if (option is QueryOption) {
      // TODO(JKRhb): Refactor?
      final queryParameter = option.value.replaceAll('&', '%26');

      if (query.isEmpty) {
        query = queryParameter;
        continue;
      }

      query = '$query&$queryParameter';
    }
  }

  // Step 7 of the algorithm
  if (path.isEmpty) {
    path = '/';
  }

  return Uri(
    scheme: scheme,
    host: host,
    port: port,
    path: path,
    query: query,
  );
}

/// Converts a [uri] into a list of [Option]s as specified
/// in [RFC 7252, section 6.4].
///
/// If the [uri]'s host component should equal the [destinationAddress], no
/// [UriHostOption] will be included in the returned [List] of [Option]s.
/// Similarly, if the default port for the provided URI scheme should be used,
/// it will be omitted as an [Option].
///
/// [RFC 7252, section 6.4]: https://www.rfc-editor.org/rfc/rfc7252.html#section-6.4
List<Option<Object?>> uriToOptions(
  final Uri uri,
  final InternetAddress? destinationAddress, {
  final bool includePort = false,
  final bool includeHost = false,
}) {
  final options = <Option<Object?>>[];

  if (!uri.isAbsolute) {
    throw FormatException('Provided request URI $uri is not absolute.');
  }

  if (uri.hasFragment) {
    throw FormatException(
      '$uri contains a URI fragment, which is not allowed',
    );
  }

  final host = uri.host;
  if (includeHost || host != destinationAddress?.address) {
    options.add(UriHostOption(host));
  }

  if (includePort) {
    options.add(UriPortOption(uri.port));
  }

  options
    ..addAll(_uriPathsToOptions<UriPathOption>(uri))
    ..addAll(_uriQueriesToOptions<UriQueryOption>(uri));

  return options;
}

/// Converts a relative [location] URI into a list of [Option]s.
List<Option<Object?>> locationToOptions(final Uri location) => [
      ..._uriPathsToOptions<LocationPathOption>(location),
      ..._uriQueriesToOptions<LocationQueryOption>(location)
    ];

/// Converts a [uri]'s path components into a list of [PathOption]s as specified
/// in [RFC 7252, section 6.4].
///
/// [RFC 7252, section 6.4]: https://www.rfc-editor.org/rfc/rfc7252.html#section-6.4
List<Option<Object?>> _uriPathsToOptions<T extends PathOption>(final Uri uri) {
  final options = <Option<Object?>>[];

  final path = uri.path;
  if (path.isNotEmpty && path != '/') {
    final optionValues = path.split('/').map(Uri.decodeFull);

    for (final optionValue in optionValues.skip(1)) {
      switch (T) {
        case UriPathOption:
          options.add(UriPathOption(optionValue));
          continue;
        case LocationPathOption:
          options.add(LocationPathOption(optionValue));
          continue;
      }

      throw ArgumentError('Specified invalid option type $T');
    }
  }

  return options;
}

/// Converts a [uri]'s query parameters into a list of [QueryOption]s as
/// specified in [RFC 7252, section 6.4].
///
/// [RFC 7252, section 6.4]: https://www.rfc-editor.org/rfc/rfc7252.html#section-6.4
List<Option<Object?>> _uriQueriesToOptions<T extends QueryOption>(
  final Uri uri,
) {
  final options = <Option<Object?>>[];

  for (final queryParameter in uri.queryParameters.entries) {
    final components = [queryParameter.key];
    final value = queryParameter.value;

    if (value.isNotEmpty) {
      components.add(value);
    }

    final optionValue = components.map(Uri.decodeFull).join('=');

    switch (T) {
      case UriQueryOption:
        options.add(UriQueryOption(optionValue));
        continue;
      case LocationQueryOption:
        options.add(LocationQueryOption(optionValue));
        continue;
    }

    throw ArgumentError('Specified invalid option type $T');
  }

  return options;
}
