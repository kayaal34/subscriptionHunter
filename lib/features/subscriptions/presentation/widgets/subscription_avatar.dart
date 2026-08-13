import 'package:flutter/material.dart';

import '../../../../core/constants/preset_catalog.dart';
import '../../../../shared/widgets/subscription_logo.dart';
import '../../domain/subscription.dart';

/// The brand mark for a [Subscription], wherever one is shown.
///
/// Every screen used to build a [SubscriptionLogo] by hand, and they drifted:
/// the upcoming-payments strip passed no `logoUrl` at all, so Disney+ rendered
/// as a bare "D" while the same subscription showed its real logo in the list.
/// Routing all of them through here keeps one definition of what a
/// subscription looks like.
class SubscriptionAvatar extends StatelessWidget {
  const SubscriptionAvatar({
    required this.subscription,
    this.size = 52,
    super.key,
  });

  final Subscription subscription;
  final double size;

  @override
  Widget build(BuildContext context) => SubscriptionLogo(
    monogram: monogramFor(subscription),
    brandColor: subscription.brandColor,
    assetPath: subscription.logoAsset,
    logoUrl: subscription.logoUrl,
    size: size,
  );
}

/// Letters drawn on the fallback tile when no logo image is available.
///
/// Prefers the preset's hand-picked monogram ("YT" for YouTube Premium) and
/// falls back to initials derived from the name for custom subscriptions.
String monogramFor(Subscription subscription) {
  final preset = PresetCatalog.byId(subscription.presetId);
  if (preset != null) return preset.monogram;
  return initialsOf(subscription.name);
}

/// Up to two initials from a free-text name.
String initialsOf(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return '?';
  if (words.length == 1) {
    final word = words.first;
    return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
  }
  return (words[0][0] + words[1][0]).toUpperCase();
}
