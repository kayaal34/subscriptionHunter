import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

/// Brand mark for a subscription.
///
/// Resolution order, each step a fallback for the one before:
///
/// 1. **Real logo from the network** (Clearbit), fetched once and cached on
///    disk by `cached_network_image` - later launches are instant and offline.
/// 2. **Shimmer placeholder** while that request is in flight, so the row has
///    no blank gap and no layout shift.
/// 3. **Brand-colour avatar with the service's initial**, used when there is no
///    domain, no network, or the domain has no logo. This is the guaranteed
///    path: it needs nothing but the brand colour.
///
/// A bundled SVG tile (`assets/logos/<id>.svg`) backs the avatar when one
/// exists, so presets keep their exact brand colour offline.
class SubscriptionLogo extends StatelessWidget {
  const SubscriptionLogo({
    required this.monogram,
    required this.brandColor,
    this.assetPath,
    this.logoUrl,
    this.size = 52,
    super.key,
  });

  final String monogram;
  final int brandColor;
  final String? assetPath;
  final String? logoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.28;
    final fallback = _BrandAvatar(
      monogram: monogram,
      brandColor: brandColor,
      assetPath: assetPath,
      size: size,
      radius: radius,
    );

    if (logoUrl == null) return fallback;

    return CachedNetworkImage(
      imageUrl: logoUrl!,
      width: size,
      height: size,
      fadeInDuration: const Duration(milliseconds: 220),
      placeholder: (_, _) => _LogoShimmer(size: size, radius: radius),
      // Any failure - offline, 404, DNS - lands on the branded avatar, so a
      // missing logo never reads as a broken image.
      errorWidget: (_, _, _) => fallback,
      imageBuilder: (_, image) => Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.12),
        decoration: BoxDecoration(
          // Brand marks are drawn for a light background; without this, dark
          // logos vanish in dark mode.
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Image(image: image, fit: BoxFit.contain),
      ),
    );
  }
}

/// Shimmering placeholder shown while the real logo downloads.
class _LogoShimmer extends StatelessWidget {
  const _LogoShimmer({required this.size, required this.radius});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.black12,
      highlightColor: isDark ? Colors.white24 : Colors.black.withValues(
        alpha: 0.04,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Brand-colour tile with the service's initial - the guaranteed fallback.
class _BrandAvatar extends StatelessWidget {
  const _BrandAvatar({
    required this.monogram,
    required this.brandColor,
    required this.assetPath,
    required this.size,
    required this.radius,
  });

  final String monogram;
  final int brandColor;
  final String? assetPath;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = Color(brandColor);
    // Yellow-ish brands (Exxen, Audible) need dark text to stay readable.
    final onBrand = color.computeLuminance() > 0.55
        ? Colors.black.withValues(alpha: 0.82)
        : Colors.white;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (assetPath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: SvgPicture.asset(
                assetPath!,
                fit: BoxFit.cover,
                placeholderBuilder: (_) => ColoredBox(color: color),
              ),
            )
          else
            DecoratedBox(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size * 0.14),
                child: Text(
                  monogram,
                  style: TextStyle(
                    color: onBrand,
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
