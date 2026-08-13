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

  static const List<AppLanguage> languages = [
    AppLanguage(null, 'System'),
    AppLanguage('tr', 'Türkçe'),
    AppLanguage('en', 'English'),
    AppLanguage('ru', 'Русский'),
  ];
}
