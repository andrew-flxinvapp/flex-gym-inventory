import 'package:intl/intl.dart';

/// A central helper for all date and time operations.
/// Keeps formatting consistent across the entire app.
class DateUtilsFGI {
  // -----------------------------
  // Formatters
  // -----------------------------

  /// Default format used for display: `MMM d, yyyy` (e.g., Mar 5, 2025)
  static final DateFormat displayDate = DateFormat('MMM d, yyyy');

  /// Format with time included: `MMM d, yyyy • h:mm a`
  static final DateFormat displayDateTime = DateFormat('MMM d, yyyy • h:mm a');

  /// Compact numeric format for logs or export filenames: `yyyyMMdd_HHmmss`
  static final DateFormat compactTimestamp = DateFormat('yyyyMMdd_HHmmss');

  // -----------------------------
  // Core helpers
  // -----------------------------

  /// Returns the current UTC time (used for stored timestamps)
  static DateTime nowUtc() => DateTime.now().toUtc();

  /// Returns the current local time
  static DateTime nowLocal() => DateTime.now().toLocal();

  /// Converts a stored UTC time into local display format
  static String toLocalDisplay(DateTime? utcTime, {bool includeTime = false}) {
    if (utcTime == null) return '—';
    final local = utcTime.toLocal();
    return includeTime
        ? displayDateTime.format(local)
        : displayDate.format(local);
  }

  /// Converts a DateTime to a compact string for filenames or exports.
  static String toCompactString(DateTime time) =>
      compactTimestamp.format(time);

  /// Parses an ISO 8601 string safely into a DateTime (returns null if invalid)
  static DateTime? tryParseIso(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value).toUtc();
    } catch (_) {
      return null;
    }
  }

  /// Returns a human-friendly relative time (e.g., "3d ago", "just now")
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  // -----------------------------
  // Timestamp helpers for storage
  // -----------------------------

  /// Returns ISO 8601 string for consistent Supabase/Isar storage
  static String isoNow() => DateTime.now().toUtc().toIso8601String();

  /// Converts a DateTime into an ISO 8601 string for saving
  static String toIsoString(DateTime date) => date.toUtc().toIso8601String();
}
