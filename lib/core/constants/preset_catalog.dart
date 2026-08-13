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
    // ---- Video streaming -------------------------------------------
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
      id: 'paramount_plus',
      name: 'Paramount+',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFF0064FF,
      monogram: 'P+',
      domain: 'paramountplus.com',
    ),
    PresetService(
      id: 'hulu',
      name: 'Hulu',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFF1CE783,
      monogram: 'H',
      domain: 'hulu.com',
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
    PresetService(
      id: 'tod',
      name: 'TOD',
      category: SubscriptionCategory.streaming,
      brandColor: 0xFF00A0DC,
      monogram: 'TD',
      domain: 'todtv.com.tr',
    ),

    // ---- Music & audio ---------------------------------------------
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
      id: 'deezer',
      name: 'Deezer',
      category: SubscriptionCategory.music,
      brandColor: 0xFFA238FF,
      monogram: 'Dz',
      domain: 'deezer.com',
    ),
    PresetService(
      id: 'tidal',
      name: 'TIDAL',
      category: SubscriptionCategory.music,
      brandColor: 0xFF000000,
      monogram: 'TI',
      domain: 'tidal.com',
    ),
    PresetService(
      id: 'amazon_music',
      name: 'Amazon Music',
      category: SubscriptionCategory.music,
      brandColor: 0xFF25D1DA,
      monogram: 'AZ',
      domain: 'music.amazon.com',
    ),
    PresetService(
      id: 'soundcloud',
      name: 'SoundCloud Go',
      category: SubscriptionCategory.music,
      brandColor: 0xFFFF5500,
      monogram: 'SC',
      domain: 'soundcloud.com',
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
    PresetService(
      id: 'fizy',
      name: 'fizy',
      category: SubscriptionCategory.music,
      brandColor: 0xFF7B2FF7,
      monogram: 'fz',
      domain: 'fizy.com',
    ),

    // ---- AI assistants ---------------------------------------------
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
      id: 'gemini',
      name: 'Gemini Advanced',
      category: SubscriptionCategory.ai,
      brandColor: 0xFF4285F4,
      monogram: 'G',
      domain: 'gemini.google.com',
    ),
    PresetService(
      id: 'perplexity',
      name: 'Perplexity Pro',
      category: SubscriptionCategory.ai,
      brandColor: 0xFF20808D,
      monogram: 'Px',
      domain: 'perplexity.ai',
    ),
    PresetService(
      id: 'midjourney',
      name: 'Midjourney',
      category: SubscriptionCategory.ai,
      brandColor: 0xFF2B2B2B,
      monogram: 'MJ',
      domain: 'midjourney.com',
    ),
    PresetService(
      id: 'github_copilot',
      name: 'GitHub Copilot',
      category: SubscriptionCategory.ai,
      brandColor: 0xFF24292F,
      monogram: 'CP',
      domain: 'github.com',
    ),

    // ---- Software & productivity -----------------------------------
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
    PresetService(
      id: 'slack',
      name: 'Slack',
      category: SubscriptionCategory.software,
      brandColor: 0xFF4A154B,
      monogram: 'SL',
      domain: 'slack.com',
    ),
    PresetService(
      id: 'zoom',
      name: 'Zoom',
      category: SubscriptionCategory.software,
      brandColor: 0xFF2D8CFF,
      monogram: 'Z',
      domain: 'zoom.us',
    ),
    PresetService(
      id: 'jetbrains',
      name: 'JetBrains',
      category: SubscriptionCategory.software,
      brandColor: 0xFFFE315D,
      monogram: 'JB',
      defaultCycle: BillingCycle.yearly,
      domain: 'jetbrains.com',
    ),
    PresetService(
      id: 'grammarly',
      name: 'Grammarly',
      category: SubscriptionCategory.software,
      brandColor: 0xFF15C39A,
      monogram: 'Gr',
      defaultCycle: BillingCycle.yearly,
      domain: 'grammarly.com',
    ),
    PresetService(
      id: 'onepassword',
      name: '1Password',
      category: SubscriptionCategory.software,
      brandColor: 0xFF0572EC,
      monogram: '1P',
      defaultCycle: BillingCycle.yearly,
      domain: '1password.com',
    ),
    PresetService(
      id: 'nordvpn',
      name: 'NordVPN',
      category: SubscriptionCategory.software,
      brandColor: 0xFF4687FF,
      monogram: 'NV',
      defaultCycle: BillingCycle.yearly,
      domain: 'nordvpn.com',
    ),
    PresetService(
      id: 'expressvpn',
      name: 'ExpressVPN',
      category: SubscriptionCategory.software,
      brandColor: 0xFFDA3940,
      monogram: 'EV',
      defaultCycle: BillingCycle.yearly,
      domain: 'expressvpn.com',
    ),

    // ---- Cloud storage ---------------------------------------------
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
    PresetService(
      id: 'onedrive',
      name: 'OneDrive',
      category: SubscriptionCategory.cloud,
      brandColor: 0xFF0078D4,
      monogram: 'OD',
      defaultCycle: BillingCycle.yearly,
      domain: 'onedrive.live.com',
    ),
    PresetService(
      id: 'backblaze',
      name: 'Backblaze',
      category: SubscriptionCategory.cloud,
      brandColor: 0xFFE21E29,
      monogram: 'BB',
      defaultCycle: BillingCycle.yearly,
      domain: 'backblaze.com',
    ),
    PresetService(
      id: 'pcloud',
      name: 'pCloud',
      category: SubscriptionCategory.cloud,
      brandColor: 0xFF15BE53,
      monogram: 'pC',
      defaultCycle: BillingCycle.yearly,
      domain: 'pcloud.com',
    ),

    // ---- Gaming ----------------------------------------------------
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
      id: 'ea_play',
      name: 'EA Play',
      category: SubscriptionCategory.gaming,
      brandColor: 0xFFFF4747,
      monogram: 'EA',
      domain: 'ea.com',
    ),
    PresetService(
      id: 'ubisoft_plus',
      name: 'Ubisoft+',
      category: SubscriptionCategory.gaming,
      brandColor: 0xFF0F3B5F,
      monogram: 'UB',
      domain: 'ubisoft.com',
    ),
    PresetService(
      id: 'geforce_now',
      name: 'GeForce NOW',
      category: SubscriptionCategory.gaming,
      brandColor: 0xFF76B900,
      monogram: 'GF',
      domain: 'nvidia.com',
    ),
    PresetService(
      id: 'apple_arcade',
      name: 'Apple Arcade',
      category: SubscriptionCategory.gaming,
      brandColor: 0xFF1C1C1E,
      monogram: 'AA',
      domain: 'apple.com',
    ),
    PresetService(
      id: 'discord_nitro',
      name: 'Discord Nitro',
      category: SubscriptionCategory.gaming,
      brandColor: 0xFF5865F2,
      monogram: 'DN',
      domain: 'discord.com',
    ),
    PresetService(
      id: 'twitch',
      name: 'Twitch Turbo',
      category: SubscriptionCategory.gaming,
      brandColor: 0xFF9146FF,
      monogram: 'TW',
      domain: 'twitch.tv',
    ),
    PresetService(
      id: 'roblox_premium',
      name: 'Roblox Premium',
      category: SubscriptionCategory.gaming,
      brandColor: 0xFFE2231A,
      monogram: 'RB',
      domain: 'roblox.com',
    ),

    // ---- News & reading --------------------------------------------
    PresetService(
      id: 'nytimes',
      name: 'The New York Times',
      category: SubscriptionCategory.news,
      brandColor: 0xFF121212,
      monogram: 'NY',
      domain: 'nytimes.com',
    ),
    PresetService(
      id: 'economist',
      name: 'The Economist',
      category: SubscriptionCategory.news,
      brandColor: 0xFFE3120B,
      monogram: 'Ec',
      defaultCycle: BillingCycle.yearly,
      domain: 'economist.com',
    ),
    PresetService(
      id: 'medium',
      name: 'Medium',
      category: SubscriptionCategory.news,
      brandColor: 0xFF191919,
      monogram: 'Me',
      domain: 'medium.com',
    ),
    PresetService(
      id: 'blinkist',
      name: 'Blinkist',
      category: SubscriptionCategory.news,
      brandColor: 0xFF2CE080,
      monogram: 'Bk',
      defaultCycle: BillingCycle.yearly,
      domain: 'blinkist.com',
    ),

    // ---- Fitness ---------------------------------------------------
    PresetService(
      id: 'strava',
      name: 'Strava',
      category: SubscriptionCategory.fitness,
      brandColor: 0xFFFC4C02,
      monogram: 'SV',
      defaultCycle: BillingCycle.yearly,
      domain: 'strava.com',
    ),
    PresetService(
      id: 'fitbit_premium',
      name: 'Fitbit Premium',
      category: SubscriptionCategory.fitness,
      brandColor: 0xFF00B0B9,
      monogram: 'FB',
      domain: 'fitbit.com',
    ),
    PresetService(
      id: 'myfitnesspal',
      name: 'MyFitnessPal',
      category: SubscriptionCategory.fitness,
      brandColor: 0xFF0072EF,
      monogram: 'MF',
      domain: 'myfitnesspal.com',
    ),
    PresetService(
      id: 'peloton',
      name: 'Peloton',
      category: SubscriptionCategory.fitness,
      brandColor: 0xFFDF1E26,
      monogram: 'PL',
      domain: 'onepeloton.com',
    ),
    PresetService(
      id: 'nike_training',
      name: 'Nike Training Club',
      category: SubscriptionCategory.fitness,
      brandColor: 0xFF111111,
      monogram: 'NK',
      domain: 'nike.com',
    ),

    // ---- Learning --------------------------------------------------
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
    PresetService(
      id: 'coursera',
      name: 'Coursera Plus',
      category: SubscriptionCategory.education,
      brandColor: 0xFF0056D2,
      monogram: 'CO',
      defaultCycle: BillingCycle.yearly,
      domain: 'coursera.org',
    ),
    PresetService(
      id: 'udemy',
      name: 'Udemy Personal',
      category: SubscriptionCategory.education,
      brandColor: 0xFFA435F0,
      monogram: 'UD',
      defaultCycle: BillingCycle.yearly,
      domain: 'udemy.com',
    ),
    PresetService(
      id: 'skillshare',
      name: 'Skillshare',
      category: SubscriptionCategory.education,
      brandColor: 0xFF002333,
      monogram: 'SK',
      defaultCycle: BillingCycle.yearly,
      domain: 'skillshare.com',
    ),
    PresetService(
      id: 'babbel',
      name: 'Babbel',
      category: SubscriptionCategory.education,
      brandColor: 0xFFFF6E00,
      monogram: 'BA',
      defaultCycle: BillingCycle.yearly,
      domain: 'babbel.com',
    ),
  ];

  /// Presets grouped by category, preserving catalog order.
  ///
  /// The picker shows 75 services; an ungrouped grid of that size is a wall of
  /// icons, so it is rendered under category headings instead.
  static Map<SubscriptionCategory, List<PresetService>> groupByCategory(
    List<PresetService> presets,
  ) {
    final grouped = <SubscriptionCategory, List<PresetService>>{};
    for (final preset in presets) {
      grouped.putIfAbsent(preset.category, () => []).add(preset);
    }
    return grouped;
  }

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
