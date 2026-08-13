/// Languages offered by the in-app switcher.
///
/// `code == null` means "follow the device language". Keeping the display
/// names as endonyms (Türkçe, not "Turkish") means a user who cannot read the
/// current language can still find their own.
class AppLanguage {
  const AppLanguage(this.code, this.endonym);

  final String? code;
  final String endonym;
}

abstract final class AppConstants {
  /// Keep in sync with `version:` in pubspec.yaml.
  static const String version = '1.0.0';

  /// Publicly hosted copy of the privacy policy.
  ///
  /// Google Play requires a reachable URL on the store listing - an in-app
  /// screen alone is not accepted. The text lives in PRIVACY_POLICY.md at the
  /// repository root; publish it (GitHub Pages serves it for free) and put the
  /// resulting address here before submitting the listing.
  static const String privacyPolicyUrl =
      'https://github.com/kodmod034/subscriptionHunter/blob/main/PRIVACY_POLICY.md';

  static const List<AppLanguage> languages = [
    AppLanguage(null, 'System'),
    AppLanguage('tr', 'Türkçe'),
    AppLanguage('en', 'English'),
    AppLanguage('ru', 'Русский'),
  ];
}
