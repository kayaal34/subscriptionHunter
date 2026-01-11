/// Category enum for organizing subscriptions
enum SubscriptionCategory {
  entertainment,
  software,
  productivity,
  streaming,
  health,
  social,
  cloud,
  other,
}

/// Extension methods for SubscriptionCategory
extension CategoryName on SubscriptionCategory {
  String getDisplayName(String languageCode) {
    switch (this) {
      case SubscriptionCategory.entertainment:
        return languageCode == 'tr' ? 'Eğlence' : languageCode == 'ru' ? 'Развлечения' : 'Entertainment';
      case SubscriptionCategory.software:
        return languageCode == 'tr' ? 'Yazılım' : languageCode == 'ru' ? 'Программное обеспечение' : 'Software';
      case SubscriptionCategory.productivity:
        return languageCode == 'tr' ? 'Üretkenlik' : languageCode == 'ru' ? 'Производительность' : 'Productivity';
      case SubscriptionCategory.streaming:
        return languageCode == 'tr' ? 'Akış' : languageCode == 'ru' ? 'Потоковая передача' : 'Streaming';
      case SubscriptionCategory.health:
        return languageCode == 'tr' ? 'Sağlık' : languageCode == 'ru' ? 'Здоровье' : 'Health';
      case SubscriptionCategory.social:
        return languageCode == 'tr' ? 'Sosyal' : languageCode == 'ru' ? 'Социальное' : 'Social';
      case SubscriptionCategory.cloud:
        return languageCode == 'tr' ? 'Bulut' : languageCode == 'ru' ? 'Облако' : 'Cloud';
      case SubscriptionCategory.other:
        return languageCode == 'tr' ? 'Diğer' : languageCode == 'ru' ? 'Другое' : 'Other';
    }
  }

  String getEmoji() {
    switch (this) {
      case SubscriptionCategory.entertainment:
        return '🎬';
      case SubscriptionCategory.software:
        return '💻';
      case SubscriptionCategory.productivity:
        return '📊';
      case SubscriptionCategory.streaming:
        return '▶️';
      case SubscriptionCategory.health:
        return '🏥';
      case SubscriptionCategory.social:
        return '👥';
      case SubscriptionCategory.cloud:
        return '☁️';
      case SubscriptionCategory.other:
        return '📦';
    }
  }
}
