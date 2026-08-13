/// Currencies the app can display.
///
/// Kept deliberately small and explicit: every entry has a symbol that renders
/// correctly in the default font, and the list drives both the settings picker
/// and the add-subscription form.
class AppCurrency {
  const AppCurrency(this.code, this.symbol, this.englishName);

  final String code;
  final String symbol;
  final String englishName;
}

abstract final class Currencies {
  static const List<AppCurrency> all = [
    AppCurrency('TRY', '₺', 'Turkish lira'),
    AppCurrency('USD', r'$', 'US dollar'),
    AppCurrency('EUR', '€', 'Euro'),
    AppCurrency('GBP', '£', 'British pound'),
    AppCurrency('RUB', '₽', 'Russian ruble'),
    AppCurrency('AZN', '₼', 'Azerbaijani manat'),
    AppCurrency('CHF', 'CHF', 'Swiss franc'),
    AppCurrency('JPY', '¥', 'Japanese yen'),
    AppCurrency('CAD', r'C$', 'Canadian dollar'),
    AppCurrency('AUD', r'A$', 'Australian dollar'),
    AppCurrency('INR', '₹', 'Indian rupee'),
    AppCurrency('AED', 'AED', 'UAE dirham'),
  ];

  static const String fallbackCode = 'TRY';

  static AppCurrency byCode(String code) => all.firstWhere(
    (c) => c.code == code,
    orElse: () => all.firstWhere((c) => c.code == fallbackCode),
  );

  static String symbolOf(String code) => byCode(code).symbol;

  /// Best-guess currency for a device locale, used only for the very first
  /// launch before the user picks one.
  static String forCountryCode(String? countryCode) => switch (countryCode) {
    'TR' => 'TRY',
    'US' => 'USD',
    'GB' => 'GBP',
    'RU' => 'RUB',
    'AZ' => 'AZN',
    'CH' => 'CHF',
    'JP' => 'JPY',
    'CA' => 'CAD',
    'AU' => 'AUD',
    'IN' => 'INR',
    'AE' => 'AED',
    'DE' ||
    'FR' ||
    'IT' ||
    'ES' ||
    'NL' ||
    'PT' ||
    'IE' ||
    'AT' ||
    'BE' ||
    'FI' ||
    'GR' => 'EUR',
    _ => fallbackCode,
  };
}
