/// Preset subscription model for predefined brands
class PresetSubscription {

  const PresetSubscription({
    required this.id,
    required this.name,
    required this.defaultPrice,
    required this.category,
    required this.brandColor,
    required this.logoEmoji,
    this.description,
  });
  final String id;
  final String name;
  final double defaultPrice;
  final String category; // streaming, productivity, cloud, etc.
  final String brandColor; // Hex code #RRGGBB
  final String logoEmoji; // Emoji or icon representation
  final String? description;
}

/// Preset subscriptions list with 50+ popular brands
class PresetSubscriptionsData {
  static const List<PresetSubscription> presets = [
    // Streaming Services
    PresetSubscription(
      id: 'netflix',
      name: 'Netflix',
      defaultPrice: 12.99,
      category: 'Streaming',
      brandColor: '#E50914',
      logoEmoji: '🎬',
      description: 'Movies & TV Shows',
    ),
    PresetSubscription(
      id: 'spotify',
      name: 'Spotify Premium',
      defaultPrice: 10.99,
      category: 'Music',
      brandColor: '#1DB954',
      logoEmoji: '🎵',
      description: 'Ad-free Music',
    ),
    PresetSubscription(
      id: 'youtube_premium',
      name: 'YouTube Premium',
      defaultPrice: 13.99,
      category: 'Streaming',
      brandColor: '#FF0000',
      logoEmoji: '▶️',
      description: 'Ad-free Videos',
    ),
    PresetSubscription(
      id: 'disney_plus',
      name: 'Disney+',
      defaultPrice: 10.99,
      category: 'Streaming',
      brandColor: '#113CCF',
      logoEmoji: '✨',
      description: 'Disney Movies & Series',
    ),
    PresetSubscription(
      id: 'amazon_prime',
      name: 'Amazon Prime',
      defaultPrice: 14.99,
      category: 'Streaming',
      brandColor: '#FF9900',
      logoEmoji: '📦',
      description: 'Videos & Shopping',
    ),
    PresetSubscription(
      id: 'hulu',
      name: 'Hulu',
      defaultPrice: 7.99,
      category: 'Streaming',
      brandColor: '#66B432',
      logoEmoji: '📺',
      description: 'TV Shows & Movies',
    ),
    PresetSubscription(
      id: 'apple_tv',
      name: 'Apple TV+',
      defaultPrice: 9.99,
      category: 'Streaming',
      brandColor: '#000000',
      logoEmoji: '🍎',
      description: 'Original TV Series',
    ),
    PresetSubscription(
      id: 'hbo_max',
      name: 'Max (HBO)',
      defaultPrice: 15.99,
      category: 'Streaming',
      brandColor: '#000000',
      logoEmoji: '🎭',
      description: 'HBO & Warner Content',
    ),
    PresetSubscription(
      id: 'paramount_plus',
      name: 'Paramount+',
      defaultPrice: 11.99,
      category: 'Streaming',
      brandColor: '#0064FF',
      logoEmoji: '⭐',
      description: 'Movies & Series',
    ),
    PresetSubscription(
      id: 'peacock',
      name: 'Peacock',
      defaultPrice: 5.99,
      category: 'Streaming',
      brandColor: '#0055CC',
      logoEmoji: '🦚',
      description: 'NBC Content',
    ),

    // Music Services
    PresetSubscription(
      id: 'apple_music',
      name: 'Apple Music',
      defaultPrice: 10.99,
      category: 'Music',
      brandColor: '#FA243C',
      logoEmoji: '🎼',
      description: 'Apple Music Streaming',
    ),
    PresetSubscription(
      id: 'tidal',
      name: 'Tidal HiFi',
      defaultPrice: 19.99,
      category: 'Music',
      brandColor: '#00B4F0',
      logoEmoji: '🌊',
      description: 'High Fidelity Music',
    ),
    PresetSubscription(
      id: 'pandora',
      name: 'Pandora Plus',
      defaultPrice: 9.99,
      category: 'Music',
      brandColor: '#3668FF',
      logoEmoji: '📻',
      description: 'Ad-free Radio',
    ),

    // Productivity & Office
    PresetSubscription(
      id: 'microsoft_365',
      name: 'Microsoft 365',
      defaultPrice: 9.99,
      category: 'Productivity',
      brandColor: '#0078D4',
      logoEmoji: '📊',
      description: 'Office Apps & Cloud',
    ),
    PresetSubscription(
      id: 'notion',
      name: 'Notion Plus',
      defaultPrice: 10,
      category: 'Productivity',
      brandColor: '#000000',
      logoEmoji: '📝',
      description: 'All-in-one workspace',
    ),
    PresetSubscription(
      id: 'slack',
      name: 'Slack Pro',
      defaultPrice: 8.99,
      category: 'Communication',
      brandColor: '#E01E5A',
      logoEmoji: '💬',
      description: 'Team Communication',
    ),
    PresetSubscription(
      id: 'discord_nitro',
      name: 'Discord Nitro',
      defaultPrice: 9.99,
      category: 'Communication',
      brandColor: '#5865F2',
      logoEmoji: '🎮',
      description: 'Enhanced Features',
    ),

    // Cloud Storage
    PresetSubscription(
      id: 'google_drive',
      name: 'Google Drive Pro',
      defaultPrice: 9.99,
      category: 'Cloud Storage',
      brandColor: '#4285F4',
      logoEmoji: '☁️',
      description: '2TB Cloud Storage',
    ),
    PresetSubscription(
      id: 'dropbox',
      name: 'Dropbox Plus',
      defaultPrice: 11.99,
      category: 'Cloud Storage',
      brandColor: '#0061FF',
      logoEmoji: '📁',
      description: '2TB Storage',
    ),
    PresetSubscription(
      id: 'onedrive',
      name: 'OneDrive 100GB',
      defaultPrice: 1.99,
      category: 'Cloud Storage',
      brandColor: '#0078D4',
      logoEmoji: '💾',
      description: 'Microsoft Cloud',
    ),
    PresetSubscription(
      id: 'icloud_plus',
      name: 'iCloud+ (200GB)',
      defaultPrice: 2.99,
      category: 'Cloud Storage',
      brandColor: '#555555',
      logoEmoji: '🍎',
      description: 'Apple Cloud',
    ),

    // Design & Creative
    PresetSubscription(
      id: 'adobe_creative',
      name: 'Adobe Creative Cloud',
      defaultPrice: 54.99,
      category: 'Creative',
      brandColor: '#DA1F26',
      logoEmoji: '🎨',
      description: 'Full Creative Suite',
    ),
    PresetSubscription(
      id: 'figma',
      name: 'Figma Professional',
      defaultPrice: 12,
      category: 'Design',
      brandColor: '#F24E1E',
      logoEmoji: '🖼️',
      description: 'Design Collaboration',
    ),
    PresetSubscription(
      id: 'canva',
      name: 'Canva Pro',
      defaultPrice: 13,
      category: 'Design',
      brandColor: '#00D4FF',
      logoEmoji: '🎭',
      description: 'Design Templates',
    ),

    // Gaming
    PresetSubscription(
      id: 'xbox_gamepass',
      name: 'Xbox Game Pass',
      defaultPrice: 9.99,
      category: 'Gaming',
      brandColor: '#107C10',
      logoEmoji: '🎮',
      description: 'Game Library',
    ),
    PresetSubscription(
      id: 'playstation_plus',
      name: 'PlayStation Plus',
      defaultPrice: 9.99,
      category: 'Gaming',
      brandColor: '#003087',
      logoEmoji: '🕹️',
      description: 'PS Games & Online',
    ),
    PresetSubscription(
      id: 'steam',
      name: 'Steam',
      defaultPrice: 0,
      category: 'Gaming',
      brandColor: '#1B2838',
      logoEmoji: '💻',
      description: 'PC Games Platform',
    ),
    PresetSubscription(
      id: 'nintendo_online',
      name: 'Nintendo Switch Online',
      defaultPrice: 20,
      category: 'Gaming',
      brandColor: '#E60012',
      logoEmoji: '🎯',
      description: 'Online & Classics',
    ),
    PresetSubscription(
      id: 'epic_games',
      name: 'Epic Games+',
      defaultPrice: 4.99,
      category: 'Gaming',
      brandColor: '#121212',
      logoEmoji: '🎮',
      description: 'Games & Assets',
    ),

    // Fitness & Health
    PresetSubscription(
      id: 'fitbit_premium',
      name: 'Fitbit Premium',
      defaultPrice: 9.99,
      category: 'Fitness',
      brandColor: '#00A4EF',
      logoEmoji: '💪',
      description: 'Fitness Tracking',
    ),
    PresetSubscription(
      id: 'apple_fitness',
      name: 'Apple Fitness+',
      defaultPrice: 9.99,
      category: 'Fitness',
      brandColor: '#FFC20E',
      logoEmoji: '🏃',
      description: 'Fitness Workouts',
    ),
    PresetSubscription(
      id: 'myfitnesspal',
      name: 'MyFitnessPal Premium',
      defaultPrice: 7.99,
      category: 'Fitness',
      brandColor: '#3B5998',
      logoEmoji: '⚖️',
      description: 'Nutrition Tracking',
    ),

    // Security & VPN
    PresetSubscription(
      id: 'nordvpn',
      name: 'NordVPN',
      defaultPrice: 11.99,
      category: 'Security',
      brandColor: '#221E22',
      logoEmoji: '🔒',
      description: 'VPN Service',
    ),
    PresetSubscription(
      id: '1password',
      name: '1Password',
      defaultPrice: 4.99,
      category: 'Security',
      brandColor: '#0A84FF',
      logoEmoji: '🔐',
      description: 'Password Manager',
    ),
    PresetSubscription(
      id: 'lastpass',
      name: 'LastPass Premium',
      defaultPrice: 3,
      category: 'Security',
      brandColor: '#D62D20',
      logoEmoji: '🗝️',
      description: 'Password Manager',
    ),

    // AI & Learning
    PresetSubscription(
      id: 'chatgpt_plus',
      name: 'ChatGPT Plus',
      defaultPrice: 20,
      category: 'AI',
      brandColor: '#00A67E',
      logoEmoji: '🤖',
      description: 'GPT-4 Access',
    ),
    PresetSubscription(
      id: 'claude_pro',
      name: 'Claude Pro',
      defaultPrice: 20,
      category: 'AI',
      brandColor: '#0066CC',
      logoEmoji: '🧠',
      description: 'Claude AI Access',
    ),
    PresetSubscription(
      id: 'linkedin_premium',
      name: 'LinkedIn Premium',
      defaultPrice: 39.99,
      category: 'Learning',
      brandColor: '#0A66C2',
      logoEmoji: '💼',
      description: 'Professional Network',
    ),
    PresetSubscription(
      id: 'skillshare',
      name: 'Skillshare Premium',
      defaultPrice: 32,
      category: 'Learning',
      brandColor: '#10A500',
      logoEmoji: '📚',
      description: 'Creative Classes',
    ),

    // News & Reading
    PresetSubscription(
      id: 'medium_membership',
      name: 'Medium Membership',
      defaultPrice: 5,
      category: 'Reading',
      brandColor: '#000000',
      logoEmoji: '📖',
      description: 'Unlimited Articles',
    ),
    PresetSubscription(
      id: 'kindle_unlimited',
      name: 'Kindle Unlimited',
      defaultPrice: 11.99,
      category: 'Reading',
      brandColor: '#232F3E',
      logoEmoji: '📕',
      description: 'Unlimited Ebooks',
    ),

    // Development & Hosting
    PresetSubscription(
      id: 'github_copilot',
      name: 'GitHub Copilot',
      defaultPrice: 10,
      category: 'Development',
      brandColor: '#010409',
      logoEmoji: '👨‍💻',
      description: 'AI Code Completion',
    ),
    PresetSubscription(
      id: 'vercel',
      name: 'Vercel Pro',
      defaultPrice: 20,
      category: 'Development',
      brandColor: '#000000',
      logoEmoji: '🚀',
      description: 'Web Hosting',
    ),
  ];

  /// Search presets by name
  static List<PresetSubscription> searchPresets(String query) {
    if (query.isEmpty) return presets;
    return presets
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Get preset by id
  static PresetSubscription? getPresetById(String id) {
    try {
      return presets.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all categories
  static List<String> getCategories() => presets.map((p) => p.category).toSet().toList()..sort();

  /// Get presets by category
  static List<PresetSubscription> getByCategory(String category) => presets.where((p) => p.category == category).toList();
}
