/// Currency configuration for the app
class Currency {

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });
  final String code;
  final String symbol;
  final String name;

  @override
  String toString() => '$code ($symbol)';
}

/// Exchange rates to TRY (Turkish Lira) for calculation
/// Note: These are fixed rates - update them periodically with real data
class CurrencyConverter {
  static const Map<String, double> exchangeRates = {
    'TRY': 1.0,
    'USD': 41.5, // 1 USD = 33.5 TRY
    'EUR': 50, // 1 EUR = 36.5 TRY
    'RUB': 0.51, // 1 RUB = 0.32 TRY
    'GBP': 42.0, // 1 GBP = 42.0 TRY
    'JPY': 0.23, // 1 JPY = 0.23 TRY
    'CAD': 24.5, // 1 CAD = 24.5 TRY
    'AUD': 22.0, // 1 AUD = 22.0 TRY
    'CHF': 37.5, // 1 CHF = 37.5 TRY
    'CNY': 4.6, // 1 CNY = 4.6 TRY
  };

  /// Convert amount from source currency to target currency
  static double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return amount;

    final fromRate = exchangeRates[fromCurrency] ?? 1.0;
    final toRate = exchangeRates[toCurrency] ?? 1.0;

    // Convert to base currency (TRY) first, then to target
    final amountInTRY = amount * fromRate;
    return amountInTRY / toRate;
  }

  /// Convert to TRY
  static double convertToTRY({
    required double amount,
    required String currency,
  }) => convert(
      amount: amount,
      fromCurrency: currency,
      toCurrency: 'TRY',
    );
}

/// Supported currencies list
const List<Currency> supportedCurrencies = [
  Currency(code: 'TRY', symbol: '₺', name: 'Turkish Lira'),
  Currency(code: 'USD', symbol: '\$', name: 'US Dollar'),
  Currency(code: 'EUR', symbol: '€', name: 'Euro'),
  Currency(code: 'GBP', symbol: '£', name: 'British Pound'),
  Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
  Currency(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
  Currency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
  Currency(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc'),
  Currency(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
  Currency(code: 'RUB', symbol: '₽', name: 'Russian Ruble'),
];
