import '../constants/currencies.dart' as currencies_file;
import '../constants/currencies.dart'; // Import for type definition Currency

class CurrencyService {
  
  static List<Currency> get supportedCurrencies => currencies_file.supportedCurrencies;

  /// Convert amount from source currency to target currency
  double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) => CurrencyConverter.convert(
      amount: amount,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
    );

  /// Get formatted total string
  String getFormattedTotal(double amount, String currencyCode) {
    // Determine symbol
    final symbol = currencies_file.supportedCurrencies.firstWhere(
      (c) => c.code == currencyCode, 
      orElse: () => Currency(code: currencyCode, symbol: currencyCode, name: ''),
    ).symbol;

    return '$symbol${amount.toStringAsFixed(2)}';
  }
}
