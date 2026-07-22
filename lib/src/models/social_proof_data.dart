class SocialProofData {
  const SocialProofData({
    required this.userCount,
    required this.rating,
    required this.reviewCount,
    this.userLabel = 'Happy gym owners',
  });

  /// Total number of users.
  final int userCount;

  /// Average App Store rating.
  final double rating;

  /// Number of ratings/reviews.
  final int reviewCount;

  /// Text shown beneath the user count.
  final String userLabel;

  /// Example:
  /// 1042 -> 1K+
  /// 1520 -> 1.5K+
  /// 1200000 -> 1.2M+
  String get formattedUserCount {
    if (userCount >= 1000000) {
      final millions = userCount ~/ 1000000;
      return '${millions}M+';
    }

    if (userCount >= 1000) {
      final thousands = userCount ~/ 1000;
      return '${thousands}K+';
    }

    return userCount.toString();
  }

  /// Example:
  /// 4.9
  String get formattedRating =>
      rating.toStringAsFixed(1);
}