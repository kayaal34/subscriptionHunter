import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toFormattedString() => DateFormat('dd MMM yyyy').format(this);

  String toTimeString() => DateFormat('HH:mm').format(this);

  /// Get next billing date based on billing day
  static DateTime getNextBillingDate(int billingDay) {
    final now = DateTime.now();
    int nextMonth = now.month;
    int nextYear = now.year;

    if (now.day >= billingDay) {
      nextMonth = now.month + 1;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear = now.year + 1;
      }
    }

    return DateTime(nextYear, nextMonth, billingDay);
  }

  /// Get days until billing date
  static int daysUntilBilling(int billingDay) {
    final nextBilling = getNextBillingDate(billingDay);
    final now = DateTime.now();
    return nextBilling.difference(now).inDays;
  }
}

extension DoubleExtension on double {
  String toCurrency({String symbol = '\$'}) => '$symbol${toStringAsFixed(2)}';
}

extension StringExtension on String {
  /// Get icon widget for subscription
  String toIconEmoji() {
    final key = toLowerCase();
    final iconMap = {
      'streaming': '🎬',
      'music': '🎵',
      'cloud': '☁️',
      'cloud storage': '☁️',
      'fitness': '💪',
      'news': '📰',
      'gaming': '🎮',
      'vpn': '🔒',
      'education': '📚',
      'dating': '💕',
      'shopping': '🛍️',
      'food': '🍔',
      'software': '💻',
      'utility': '💡',
      'other': '📦',
    };
    return iconMap[key] ?? '📦';
  }
}
