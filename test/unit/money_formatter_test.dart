import 'package:flutter_test/flutter_test.dart';
import 'package:subscription_tracker/core/constants/currencies.dart';
import 'package:subscription_tracker/core/utils/money_formatter.dart';

void main() {
  group('format', () {
    test('uses the currency symbol', () {
      final result = MoneyFormatter.format(
        amount: 149.99,
        currencyCode: 'TRY',
        localeName: 'tr',
      );

      expect(result, contains('₺'));
      expect(result, contains('149'));
    });

    test('uses locale-appropriate separators', () {
      // Turkish uses a comma for decimals, English a period. Asserting on the
      // separator rather than the whole string keeps this robust across icu
      // data updates.
      final turkish = MoneyFormatter.format(
        amount: 1234.5,
        currencyCode: 'TRY',
        localeName: 'tr',
      );
      final english = MoneyFormatter.format(
        amount: 1234.5,
        currencyCode: 'USD',
        localeName: 'en',
      );

      expect(turkish, contains('1.234,50'));
      expect(english, contains('1,234.50'));
    });

    test('always shows two decimal places', () {
      final result = MoneyFormatter.format(
        amount: 10,
        currencyCode: 'USD',
        localeName: 'en',
      );

      expect(result, contains('10.00'));
    });

    test('handles zero', () {
      expect(
        MoneyFormatter.format(
          amount: 0,
          currencyCode: 'USD',
          localeName: 'en',
        ),
        contains('0.00'),
      );
    });
  });

  group('compact', () {
    test('drops decimals for whole amounts', () {
      final result = MoneyFormatter.compact(
        amount: 1250,
        currencyCode: 'TRY',
        localeName: 'tr',
      );

      expect(result, '₺1.250');
      expect(result, isNot(contains(',00')));
    });

    test('keeps decimals when they carry information', () {
      final result = MoneyFormatter.compact(
        amount: 1250.75,
        currencyCode: 'TRY',
        localeName: 'tr',
      );

      expect(result, contains('75'));
    });
  });

  group('Currencies', () {
    test('falls back to the default for an unknown code', () {
      expect(Currencies.byCode('XXX').code, Currencies.fallbackCode);
    });

    test('maps country codes to a sensible currency', () {
      expect(Currencies.forCountryCode('TR'), 'TRY');
      expect(Currencies.forCountryCode('DE'), 'EUR');
      expect(Currencies.forCountryCode('US'), 'USD');
    });

    test('falls back for an unmapped country', () {
      expect(Currencies.forCountryCode('ZZ'), Currencies.fallbackCode);
      expect(Currencies.forCountryCode(null), Currencies.fallbackCode);
    });

    test('every currency has a symbol', () {
      for (final currency in Currencies.all) {
        expect(currency.symbol, isNotEmpty, reason: currency.code);
        expect(currency.code.length, 3, reason: currency.code);
      }
    });
  });
}
