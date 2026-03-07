// ignore: depend_on_referenced_packages
import 'package:flutter/material.dart' show Color;

/// Shared expiration rules used by both the domain layer and the UI.
///
/// [ExpirationStatus] drives the colour coding on pantry cards:
///   [critical]   → Red   (0–1 days)
///   [urgent]     → Amber (2–6 days)
///   [safe]       → Green (7+ days / no date set)
///   [expired]    → Red/Grey (past today)
///   [noDate]     → neutral (no expiry recorded)
enum ExpirationStatus { expired, critical, urgent, safe, noDate }

class ExpirationHelper {
  const ExpirationHelper._();

  /// Returns the [ExpirationStatus] and [daysUntilExpiration] for [expiry].
  ///
  /// The [daysUntilExpiration] identifier is used by the dashboard widgets.
  static ({ExpirationStatus status, int? daysUntilExpiration}) evaluate(
    DateTime? expiry,
  ) {
    if (expiry == null) {
      return (status: ExpirationStatus.noDate, daysUntilExpiration: null);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDay =
        DateTime(expiry.year, expiry.month, expiry.day);
    final daysUntilExpiration = expiryDay.difference(today).inDays;

    final status = switch (daysUntilExpiration) {
      < 0 => ExpirationStatus.expired,
      <= 1 => ExpirationStatus.critical,
      <= 6 => ExpirationStatus.urgent,
      _ => ExpirationStatus.safe,
    };

    return (status: status, daysUntilExpiration: daysUntilExpiration);
  }

  /// Convenience: colour used for badge / card border.
  static Color colorFor(ExpirationStatus status) {
    return switch (status) {
      ExpirationStatus.expired => const Color(0xFF757575),   // Grey
      ExpirationStatus.critical => const Color(0xFFEF5350),  // Red
      ExpirationStatus.urgent => const Color(0xFFFFCA28),    // Amber
      ExpirationStatus.safe => const Color(0xFF66BB6A),      // Green
      ExpirationStatus.noDate => const Color(0xFF607D8B),    // Blue-Grey
    };
  }

  /// Convenience: human-readable label.
  static String labelFor(ExpirationStatus status, int? days) {
    return switch (status) {
      ExpirationStatus.expired => 'Expired',
      ExpirationStatus.critical => 'Expires today!',
      ExpirationStatus.urgent => 'Expires in $days days',
      ExpirationStatus.safe => '$days days left',
      ExpirationStatus.noDate => 'No expiry set',
    };
  }
}


