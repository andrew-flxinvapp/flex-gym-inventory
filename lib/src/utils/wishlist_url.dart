Uri? parseWishlistUrl(String value) {
  final input = value.trim();
  if (input.isEmpty ||
      RegExp(r'[\x00-\x20\x7f\s\\<>"]').hasMatch(input) ||
      RegExp(r'%(?![0-9a-fA-F]{2})').hasMatch(input) ||
      RegExp(
        r'%(?:0[0-9a-f]|1[0-9a-f]|7f)',
        caseSensitive: false,
      ).hasMatch(input)) {
    return null;
  }

  final hasWebScheme = RegExp(
    r'^https?://',
    caseSensitive: false,
  ).hasMatch(input);
  final hasScheme = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*:').hasMatch(input);
  final hasHostPort = RegExp(
    r'^[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+:\d+(?:[/?#]|$)',
  ).hasMatch(input);
  if (!hasWebScheme && hasScheme && !hasHostPort) return null;

  final normalized = hasWebScheme ? input : 'https://$input';
  final authority = RegExp(
    r'^https?://([^/?#]*)',
    caseSensitive: false,
  ).firstMatch(normalized)?.group(1);
  if (authority == null || authority.endsWith(':') || authority.contains('@')) {
    return null;
  }

  final uri = Uri.tryParse(normalized);
  if (uri == null ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty ||
      uri.port < 1 ||
      uri.port > 65535) {
    return null;
  }

  final String host;
  try {
    host = Uri.decodeComponent(uri.host);
  } on FormatException {
    return null;
  }
  if (host.contains(':')) {
    try {
      Uri.parseIPv6Address(host);
    } on FormatException {
      return null;
    }
  } else {
    final hostname =
        host.endsWith('.') ? host.substring(0, host.length - 1) : host;
    if (hostname.length > 253 ||
        hostname
            .split('.')
            .any(
              (label) =>
                  label.isEmpty ||
                  label.length > 63 ||
                  !RegExp(
                    r'^[\p{L}\p{N}](?:[\p{L}\p{N}\p{M}-]*[\p{L}\p{N}\p{M}])?$',
                    unicode: true,
                  ).hasMatch(label),
            )) {
      return null;
    }
    if (RegExp(r'^[0-9.]+$').hasMatch(hostname)) {
      try {
        Uri.parseIPv4Address(hostname);
      } on FormatException {
        return null;
      }
    }
  }
  return uri;
}

String? validateWishlistUrl(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return parseWishlistUrl(value) == null ? 'Enter a valid web link' : null;
}
