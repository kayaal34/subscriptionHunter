import 'package:intl/intl.dart';

import '../constants/currencies.dart';

/// Formats money for display.
///
/// Instances are cached per locale+currency because building a [NumberFormat]
/// is comparatively expensive and the subscription list formats a value for
/// every visible row on every rebuild.
abstract final class MoneyFormatter {
  static final Map<String, NumberFormat> _cache = {};

  static NumberFormat _formatter(String localeName, String currencyCode) =>
      _cache.putIfAbsent(
        '$localeName|$currencyCode',
        () => NumberFormat.currency(
          locale: localeName,
          symbol: Currencies.symbolOf(currencyCode),
          decimalDigits: 2,
        ),
      );

  /// e.g. "₺149,99" in tr, "$15.49" in en.
  static String format({
    required double amount,
    required String currencyCode,
    required String localeName,
  }) => _formatter(localeName, currencyCode).format(amount);

  /// Drops the decimals when they add nothing, for dense places like chart
  /// axis labels where "₺1.250" beats "₺1.250,00".
  static String compact({
    required double amount,
    required String currencyCode,
    required String localeName,
  }) {
    final symbol = Currencies.symbolOf(currencyCode);
    final rounded = amount.roundToDouble();
    if ((amount - rounded).abs() < 0.005) {
      return '$symbol${NumberFormat.decimalPattern(localeName).format(rounded.toInt())}';
    }
    return format(
      amount: amount,
      currencyCode: currencyCode,
      localeName: localeName,
    );
  }
}
