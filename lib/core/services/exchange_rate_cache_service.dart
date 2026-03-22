import 'package:logger/logger.dart';
import '../constants/currencies.dart';
import 'hive_encryption_service.dart';

class ExchangeRateCacheService {

  ExchangeRateCacheService({Logger? logger}) : _logger = logger ?? Logger();
  final Logger _logger;
  static const String _boxName = 'exchange_rates';
  static const String _ratesKey = 'rates';
  static const String _lastFetchKey = 'last_fetch';
  static const Duration _cacheDuration = Duration(hours: 24);

  /// Get cached rates or fetch new ones if cache is stale
  Future<Map<String, double>> getExchangeRates({
    required Future<Map<String, double>> Function() fetchRates,
  }) async {
    try {
      final box = await openEncryptedBox(_boxName);

      // Check if cache exists and is fresh
      final lastFetch = box.get(_lastFetchKey) as int?;
      if (lastFetch != null) {
        final lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetch);
        final isFresh = DateTime.now().difference(lastFetchTime) < _cacheDuration;

        if (isFresh) {
          final cachedRates = box.get(_ratesKey) as Map?;
          if (cachedRates != null) {
            final rates = cachedRates.cast<String, double>();
            _logger.i('Using cached exchange rates');
            return rates;
          }
        }
      }

      // Cache is stale or doesn't exist, fetch new rates
      _logger.i('Cache stale or missing, fetching new exchange rates');
      final newRates = await fetchRates();

      if (newRates.isNotEmpty) {
        // Update cache
        await box.put(_ratesKey, newRates);
        await box.put(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);
        _logger.i('Exchange rates cached');
        return newRates;
      }

      final fallbackRates = await getLastSuccessfulRates();
      if (fallbackRates != null && fallbackRates.isNotEmpty) {
        _logger.w('Using fallback cached exchange rates');
        return fallbackRates;
      }

      _logger.w('No cached rates available, returning default rates');
      return getDefaultRates();
    } catch (e) {
      _logger.e('Error managing exchange rate cache', error: e);
      // Try to return old cached rates even if fetch failed
      final fallbackRates = await getLastSuccessfulRates();
      if (fallbackRates != null && fallbackRates.isNotEmpty) {
        return fallbackRates;
      }
      return getDefaultRates();
    }
  }

  /// Returns the latest successfully cached rates if available.
  Future<Map<String, double>?> getLastSuccessfulRates() async {
    try {
      final box = await openEncryptedBox(_boxName);
      final cachedRates = box.get(_ratesKey) as Map?;
      if (cachedRates == null) {
        return null;
      }
      return cachedRates.cast<String, double>();
    } catch (e) {
      _logger.w('Failed to read cached exchange rates: $e');
      return null;
    }
  }

  /// Safe defaults when network and cache are both unavailable.
  Map<String, double> getDefaultRates() => {
      for (final currency in supportedCurrencies) currency.code: 1.0,
    };

  /// Clear cached rates
  Future<void> clearCache() async {
    try {
      final box = await openEncryptedBox(_boxName);
      await box.delete(_ratesKey);
      await box.delete(_lastFetchKey);
      _logger.i('Exchange rate cache cleared');
    } catch (e) {
      _logger.e('Error clearing exchange rate cache', error: e);
    }
  }
}
