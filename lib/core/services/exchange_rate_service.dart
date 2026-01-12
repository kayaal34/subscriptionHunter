import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import '../constants/currencies.dart';

class ExchangeRateService {
  final Logger _logger;
  final http.Client _httpClient;

  ExchangeRateService({
    Logger? logger,
    http.Client? httpClient,
  })  : _logger = logger ?? Logger(),
        _httpClient = httpClient ?? http.Client();

  /// Fetch live exchange rates from API and update local rates
  /// Returns map of currency code to TRY exchange rate
  Future<Map<String, double>> fetchExchangeRates() async {
    try {
      // Using a free API that doesn't require authentication
      // Getting rates for TRY (Turkish Lira) as base
      final url = Uri.parse(
        'https://open.er-api.com/v6/latest/TRY',
      );

      final response = await _httpClient
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final rates = jsonData['rates'] as Map<String, dynamic>? ?? {};

        // Convert to our format: amount of TRY per 1 unit of foreign currency
        final exchangeRates = <String, double>{};
        
        for (final currency in supportedCurrencies) {
          if (rates.containsKey(currency.code)) {
            final tryPerUnit = 1.0 / (rates[currency.code] as num).toDouble();
            exchangeRates[currency.code] = double.parse(tryPerUnit.toStringAsFixed(4));
          }
        }

        _logger.i('Exchange rates fetched successfully: $exchangeRates');
        return exchangeRates;
      } else {
        _logger.w('Failed to fetch exchange rates: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      _logger.e('Error fetching exchange rates', error: e);
      // Return empty map on error; app will use cached rates
      return {};
    }
  }

  /// Alternative API using exchangerate-api.com free tier
  /// Requires registration but provides reliable rates
  Future<Map<String, double>> fetchExchangeRatesAlternative() async {
    try {
      // Using exchangerate-api.com free tier (includes TRY)
      final url = Uri.parse(
        'https://api.exchangerate-api.com/v4/latest/TRY',
      );

      final response = await _httpClient
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final rates = jsonData['rates'] as Map<String, dynamic>? ?? {};

        final exchangeRates = <String, double>{};
        
        for (final currency in supportedCurrencies) {
          if (rates.containsKey(currency.code)) {
            final tryPerUnit = 1.0 / (rates[currency.code] as num).toDouble();
            exchangeRates[currency.code] = double.parse(tryPerUnit.toStringAsFixed(4));
          }
        }

        _logger.i('Exchange rates fetched (alternative): $exchangeRates');
        return exchangeRates;
      } else {
        _logger.w('Failed to fetch exchange rates (alternative): ${response.statusCode}');
        return {};
      }
    } catch (e) {
      _logger.e('Error fetching exchange rates (alternative)', error: e);
      return {};
    }
  }
}
