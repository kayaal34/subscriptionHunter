import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'exchange_rate_service.dart';

class ExchangeRateCacheService {
  final Logger _logger;
  static const String _boxName = 'exchange_rates';
  static const String _ratesKey = 'rates';
  static const String _lastFetchKey = 'last_fetch';
  static const Duration _cacheDuration = Duration(hours: 24);

  ExchangeRateCacheService({Logger? logger}) : _logger = logger ?? Logger();

  /// Get cached rates or fetch new ones if cache is stale
  Future<Map<String, double>> getExchangeRates({
    required ExchangeRateService exchangeRateService,
  }) async {
    try {
      final box = await Hive.openBox(_boxName);

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
      final newRates = await exchangeRateService.fetchExchangeRates();

      if (newRates.isNotEmpty) {
        // Update cache
        await box.put(_ratesKey, newRates);
        await box.put(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);
        _logger.i('Exchange rates cached');
      }

      return newRates;
    } catch (e) {
      _logger.e('Error managing exchange rate cache', error: e);
      // Try to return old cached rates even if fetch failed
      try {
        final box = await Hive.openBox(_boxName);
        final cachedRates = box.get(_ratesKey) as Map?;
        if (cachedRates != null) {
          return cachedRates.cast<String, double>();
        }
      } catch (_) {}
      return {};
    }
  }

  /// Clear cached rates
  Future<void> clearCache() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.delete(_ratesKey);
      await box.delete(_lastFetchKey);
      _logger.i('Exchange rate cache cleared');
    } catch (e) {
      _logger.e('Error clearing exchange rate cache', error: e);
    }
  }
}
