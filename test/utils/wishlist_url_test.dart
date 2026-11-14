import 'package:flex_gym_inventory/src/utils/wishlist_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes valid web addresses without losing paths or queries', () {
    final cases = {
      'https://example.com/product?a=1&b=two':
          'https://example.com/product?a=1&b=two',
      'http://example.com/product?q=bar%20bell':
          'http://example.com/product?q=bar%20bell',
      'example.com/product?color=black&size=2':
          'https://example.com/product?color=black&size=2',
      '  www.example.com/a?x=1#details  ':
          'https://www.example.com/a?x=1#details',
      "https://example.com/men's?style=men's":
          "https://example.com/men's?style=men's",
      'example.com:8080/product': 'https://example.com:8080/product',
      'https://[::1]:8080/product': 'https://[::1]:8080/product',
      'https://münich.example/product': 'https://m%C3%BCnich.example/product',
    };
    for (final entry in cases.entries) {
      expect(
        parseWishlistUrl(entry.key)?.toString(),
        entry.value,
        reason: entry.key,
      );
      expect(validateWishlistUrl(entry.key), isNull, reason: entry.key);
    }
  });

  test('rejects malformed, hostless, unsupported and unsafe addresses', () {
    final invalid = [
      '-',
      'https://',
      'https:///product',
      'https:/example.com',
      'http:example.com',
      '//example.com/product',
      'mailto:user@example.com',
      'javascript:alert(1)',
      'file:///tmp/product',
      'ftp://example.com/product',
      'https://user@example.com/product',
      'https://example.com:/product',
      'https://example.com:99999/product',
      'https://-bad.example/product',
      'https://bad..example/product',
      'https://999.1.1.1/product',
      'https://example.com/a b',
      'https://example.com/a\u0000b',
      'https://example.com/\\evil',
      'https://example.com/%zz',
      'https://example.com/%0d',
      'https://%ff.example/product',
    ];
    for (final value in invalid) {
      expect(parseWishlistUrl(value), isNull, reason: value);
      expect(validateWishlistUrl(value), isNotNull, reason: value);
    }
  });

  test('an absent or whitespace-only link is optional', () {
    expect(validateWishlistUrl(null), isNull);
    expect(validateWishlistUrl(''), isNull);
    expect(validateWishlistUrl('  '), isNull);
    expect(parseWishlistUrl('  '), isNull);
  });
}
