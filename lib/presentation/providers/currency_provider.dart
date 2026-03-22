import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/exchange_rate_service.dart';
import '../../core/services/exchange_rate_cache_service.dart';
import '../../core/constants/currencies.dart';

final loggerProvider = Provider<Logger>((ref) => Logger());

final exchangeRateServiceProvider = Provider<ExchangeRateService>((ref) => ExchangeRateService(logger: ref.watch(loggerProvider)));

final exchangeRateCacheServiceProvider = Provider<ExchangeRateCacheService>((ref) => ExchangeRateCacheService(logger: ref.watch(loggerProvider)));

// Provider to fetch and cache exchange rates
final exchangeRatesProvider = FutureProvider<Map<String, double>>((ref) async {
  final cacheService = ref.watch(exchangeRateCacheServiceProvider);
  final exchangeRateService = ref.watch(exchangeRateServiceProvider);
  
  return cacheService.getExchangeRates(
    fetchRates: exchangeRateService.fetchExchangeRates,
  );
});

// Update CurrencyConverter with live rates
final updatedCurrencyConverterProvider = FutureProvider<void>((ref) async {
  final rates = await ref.watch(exchangeRatesProvider.future);
  if (rates.isNotEmpty) {
    CurrencyConverter.exchangeRates = rates;
  }
});

final currencyServiceProvider = Provider<CurrencyService>((ref) => CurrencyService());

class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier() : super('TRY'); // Default to TRY

  String get currency => state;
  
  set currency(String code) => state = code;
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) => CurrencyNotifier());
