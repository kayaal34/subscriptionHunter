import '../../features/subscriptions/domain/billing_cycle.dart';
import '../../features/subscriptions/domain/subscription_category.dart';

/// A one-tap subscription template.
///
/// Presets exist so the common case - "I pay for Netflix" - never requires
/// typing a name, picking a colour or hunting for a logo.
class PresetService {
  const PresetService({
    required this.id,
    required this.name,
    required this.category,
    required this.brandColor,
    required this.monogram,
    this.defaultCycle = BillingCycle.monthly,
    this.domain,
  });

  final String id;
  final String name;
  final SubscriptionCategory category;

  /// Official brand colour as ARGB.
  final int brandColor;

  /// Letter(s) drawn on the bundled fallback tile.
  final String monogram;

  final BillingCycle defaultCycle;

  /// Company domain used to resolve real brand artwork at runtime.
  ///
  /// Stored as a domain rather than a full URL precisely so the provider can
  /// be swapped in one place - which already paid off once, see [logoUrl].
  final String? domain;

  /// Bundled brand-colour tile. Always present, so the picker renders offline
  /// and with no waiting.
  String get logoAsset => 'assets/logos/$id.svg';

  /// Real brand logo, fetched and cached on first use.
  ///
  /// Uses Google's favicon service, NOT Clearbit. `logo.clearbit.com` no
  /// longer resolves at all - the free Logo API was retired and the subdomain
  /// has no DNS record, so every request failed with "unknown host" and the
  /// app silently fell back to monogram tiles.
  ///
  /// Google returns PNG. DuckDuckGo's equivalent
  /// (`icons.duckduckgo.com/ip3/<domain>.ico`) was rejected because it serves
  /// ICO, which Flutter cannot decode.
  String? get logoUrl => domain == null
      ? null
      : 'https://www.google.com/s2/favicons?domain=$domain&sz=128';
}

/// The built-in service catalog.
///
/// Brand colours for the global services are the published brand hexes. The
/// Turkish services at the end use close approximations - adjust freely, they
/// only drive the card accent.
abstract final class PresetCatalog {
  static const List<PresetService> all = [
    // ---- Video streaming -------------------------------------------------
    PresetService(
      id: 'netflix',
      name: 'Netflix',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFFE50914,
      monogram: 'N',
      domain: 'netflix.com',
    ),
    PresetService(
      id: 'disney_plus',
      name: 'Disney+',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFF113CCF,
      monogram: 'D',
      domain: 'disneyplus.com',
    ),
    PresetService(
      id: 'amazon_prime',
      name: 'Amazon Prime',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFF00A8E1,
      monogram: 'P',
      defaultCycle: BillingCycle.yearly,
      domain: 'amazon.com',
    ),
    PresetService(
      id: 'youtube_premium',
      name: 'YouTube Premium',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFFFF0000,
      monogram: 'YT',
      domain: 'youtube.com',
    ),
    PresetService(
      id: 'hbo_max',
      name: 'HBO Max',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFF991EEB,
      monogram: 'M',
      domain: 'max.com',
    ),
    PresetService(
      id: 'apple_tv',
      name: 'Apple TV+',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFF1C1C1E,
      monogram: 'TV',
      domain: 'apple.com',
    ),
    PresetService(
      id: 'mubi',
      name: 'MUBI',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFF000A8C,
      monogram: 'MU',
      domain: 'mubi.com',
    ),
    PresetService(
      id: 'crunchyroll',
      name: 'Crunchyroll',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFFF47521,
      monogram: 'CR',
      domain: 'crunchyroll.com',
    ),

    // ---- Music & audio ---------------------------------------------------
    PresetService(
      id: 'spotify',
      name: 'Spotify',
      category: SubscriptionCategory.music,
      brandColor: 0xFF1DB954,
      monogram: 'S',
      domain: 'spotify.com',
    ),
    PresetService(
      id: 'apple_music',
      name: 'Apple Music',
      category: SubscriptionCategory.music,
      brandColor: 0xFFFA243C,
      monogram: 'AM',
      domain: 'apple.com',
    ),
    PresetService(
      id: 'youtube_music',
      name: 'YouTube Music',
      category: SubscriptionCategory.music,
      brandColor: 0xFFFF0000,
      monogram: 'YM',
      domain: 'music.youtube.com',
    ),
    PresetService(
      id: 'audible',
      name: 'Audible',
      category: SubscriptionCategory.music,
      brandColor: 0xFFF8991C,
      monogram: 'A',
      domain: 'audible.com',
    ),
    PresetService(
      id: 'storytel',
      name: 'Storytel',
      category: SubscriptionCategory.music,
      brandColor: 0xFFE8425C,
      monogram: 'ST',
      domain: 'storytel.com',
    ),

    // ---- AI & software ---------------------------------------------------
    PresetService(
      id: 'chatgpt',
      name: 'ChatGPT Plus',
      category: SubscriptionCategory.ai,
      brandColor: 0xFF10A37F,
      monogram: 'AI',
      domain: 'openai.com',
    ),
    PresetService(
      id: 'claude',
      name: 'Claude Pro',
      category: SubscriptionCategory.ai,
      brandColor: 0xFFD97757,
      monogram: 'C',
      domain: 'anthropic.com',
    ),
    PresetService(
      id: 'adobe_cc',
      name: 'Adobe Creative Cloud',
      category: SubscriptionCategory.software,
      brandColor: 0xFFDA1F26,
      monogram: 'Ai',
      domain: 'adobe.com',
    ),
    PresetService(
      id: 'microsoft_365',
      name: 'Microsoft 365',
      category: SubscriptionCategory.software,
      brandColor: 0xFFD83B01,
      monogram: 'M',
      defaultCycle: BillingCycle.yearly,
      domain: 'microsoft.com',
    ),
    PresetService(
      id: 'figma',
      name: 'Figma',
      category: SubscriptionCategory.software,
      brandColor: 0xFFF24E1E,
      monogram: 'F',
      domain: 'figma.com',
    ),
    PresetService(
      id: 'canva',
      name: 'Canva Pro',
      category: SubscriptionCategory.software,
      brandColor: 0xFF00C4CC,
      monogram: 'CA',
      defaultCycle: BillingCycle.yearly,
      domain: 'canva.com',
    ),
    PresetService(
      id: 'notion',
      name: 'Notion',
      category: SubscriptionCategory.software,
      brandColor: 0xFF1F1F1F,
      monogram: 'No',
      domain: 'notion.so',
    ),

    // ---- Cloud storage ---------------------------------------------------
    PresetService(
      id: 'icloud',
      name: 'iCloud+',
      category: SubscriptionCategory.cloud,
      brandColor: 0xFF3693F3,
      monogram: 'iC',
      domain: 'icloud.com',
    ),
    PresetService(
      id: 'google_one',
      name: 'Google One',
      category: SubscriptionCategory.cloud,
      brandColor: 0xFF4285F4,
      monogram: 'G1',
      domain: 'one.google.com',
    ),
    PresetService(
      id: 'dropbox',
      name: 'Dropbox',
      category: SubscriptionCategory.cloud,
      brandColor: 0xFF0061FF,
      monogram: 'Db',
      domain: 'dropbox.com',
    ),

    // ---- Gaming ----------------------------------------------------------
    PresetService(
      id: 'playstation_plus',
      name: 'PlayStation Plus',
      category: SubscriptionCategory.gaming,
      brandColor: 0xFF0070D1,
      monogram: 'PS',
      defaultCycle: BillingCycle.yearly,
      domain: 'playstation.com',
    ),
    PresetService(
      id: 'xbox_game_pass',
      name: 'Xbox Game Pass',
      category: SubscriptionCategory.gaming,
      brandColor: 0xFF107C10,
      monogram: 'XB',
      domain: 'xbox.com',
    ),
    PresetService(
      id: 'nintendo_online',
      name: 'Nintendo Switch Online',
      category: SubscriptionCategory.gaming,
      brandColor: 0xFFE60012,
      monogram: 'NS',
      defaultCycle: BillingCycle.yearly,
      domain: 'nintendo.com',
    ),
    PresetService(
      id: 'twitch',
      name: 'Twitch Turbo',
      category: SubscriptionCategory.gaming,
      brandColor: 0xFF9146FF,
      monogram: 'TW',
      domain: 'twitch.tv',
    ),

    // ---- Learning & other ------------------------------------------------
    PresetService(
      id: 'duolingo',
      name: 'Duolingo Super',
      category: SubscriptionCategory.education,
      brandColor: 0xFF58CC02,
      monogram: 'DL',
      defaultCycle: BillingCycle.yearly,
      domain: 'duolingo.com',
    ),
    PresetService(
      id: 'linkedin_premium',
      name: 'LinkedIn Premium',
      category: SubscriptionCategory.education,
      brandColor: 0xFF0A66C2,
      monogram: 'in',
      domain: 'linkedin.com',
    ),

    // ---- Turkish services ------------------------------------------------
    // Brand hexes here are approximations chosen to read well on a card.
    PresetService(
      id: 'blutv',
      name: 'BluTV',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFF0B7FD4,
      monogram: 'Bl',
      domain: 'blutv.com',
    ),
    PresetService(
      id: 'exxen',
      name: 'Exxen',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFFFFC800,
      monogram: 'Ex',
      domain: 'exxen.com',
    ),
    PresetService(
      id: 'tabii',
      name: 'tabii',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFFE8523F,
      monogram: 'tb',
      domain: 'tabii.com',
    ),
    PresetService(
      id: 'gain',
      name: 'GAIN',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFF1A1A1A,
      monogram: 'GA',
      domain: 'gain.tv',
    ),
    PresetService(
      id: 'bein_connect',
      name: 'beIN CONNECT',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFF6D1F7F,
      monogram: 'bC',
      domain: 'beinconnect.com.tr',
    ),
  ];

  static PresetService? byId(String? id) {
    if (id == null) return null;
    for (final preset in all) {
      if (preset.id == id) return preset;
    }
    return null;
  }

  /// Case-insensitive search across the catalog, used by the picker's search
  /// field.
  static List<PresetService> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((p) => p.name.toLowerCase().contains(q)).toList();
  }
}
