import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/currency_service.dart';

final currencyServiceProvider = Provider<CurrencyService>((ref) => CurrencyService());

class CurrencyNotifier extends StateNotifier<String> {
  CurrencyNotifier() : super('TRY'); // Default to TRY

  String get currency => state;
  
  set currency(String code) => state = code;
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) => CurrencyNotifier());
