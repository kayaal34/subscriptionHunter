import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:subscription_tracker/core/constants/preset_catalog.dart';
import 'package:subscription_tracker/shared/widgets/subscription_logo.dart';

import '../helpers/pump_app.dart';

void main() {
  group('fallback avatar', () {
    testWidgets('shows the monogram when there is no logo URL', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: SubscriptionLogo(monogram: 'NF', brandColor: 0xFFE50914),
        ),
        locale: const Locale('en'),
      );

      expect(find.text('NF'), findsOneWidget);
    });

    testWidgets('shows a shimmer placeholder while the logo loads', (
      tester,
    ) async {
      // settle:false because the shimmer animates indefinitely while the
      // request is in flight, so pumpAndSettle would time out.
      //
      // Only the loading state is asserted here. Whether the request
      // eventually errors depends on real network I/O, which a widget test
      // cannot advance deterministically - the offline fallback is verified
      // on device instead.
      await pumpApp(
        tester,
        const Scaffold(
          body: SubscriptionLogo(
            monogram: 'NF',
            brandColor: 0xFFE50914,
            logoUrl: 'https://logo.clearbit.com/netflix.com',
          ),
        ),
        locale: const Locale('en'),
        settle: false,
      );

      expect(find.byType(Shimmer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('picks dark text on a light brand colour', (tester) async {
      // Exxen's yellow would render white-on-yellow and be unreadable.
      await pumpApp(
        tester,
        const Scaffold(
          body: SubscriptionLogo(monogram: 'Ex', brandColor: 0xFFFFC800),
        ),
        locale: const Locale('en'),
      );

      final text = tester.widget<Text>(find.text('Ex'));
      expect(text.style?.color?.computeLuminance(), lessThan(0.5));
    });

    testWidgets('picks light text on a dark brand colour', (tester) async {
      await pumpApp(
        tester,
        const Scaffold(
          body: SubscriptionLogo(monogram: 'No', brandColor: 0xFF1F1F1F),
        ),
        locale: const Locale('en'),
      );

      final text = tester.widget<Text>(find.text('No'));
      expect(text.style?.color?.computeLuminance(), greaterThan(0.5));
    });
  });

  group('preset catalog', () {
    test('derives logo URLs from the stored domain', () {
      final netflix = PresetCatalog.byId('netflix')!;

      expect(netflix.domain, 'netflix.com');
      expect(netflix.logoUrl, contains('netflix.com'));
    });

    test('does not use Clearbit, whose logo API no longer resolves', () {
      // logo.clearbit.com has no DNS record any more; every request failed
      // with "unknown host" and silently degraded to monogram tiles.
      for (final preset in PresetCatalog.all) {
        expect(preset.logoUrl ?? '', isNot(contains('clearbit')));
      }
    });

    test('every logo URL is a PNG source Flutter can decode', () {
      // DuckDuckGo's icon endpoint was rejected for serving ICO, which
      // Flutter has no decoder for.
      for (final preset in PresetCatalog.all.where((p) => p.domain != null)) {
        expect(preset.logoUrl, startsWith('https://'));
        expect(preset.logoUrl ?? '', isNot(endsWith('.ico')));
      }
    });

    test('every preset has a bundled asset path and a monogram', () {
      for (final preset in PresetCatalog.all) {
        expect(preset.logoAsset, 'assets/logos/${preset.id}.svg');
        expect(preset.monogram, isNotEmpty, reason: preset.id);
      }
    });

    test('brand colours are fully opaque 32-bit ARGB values', () {
      // A short hex literal silently produces a transparent colour.
      for (final preset in PresetCatalog.all) {
        expect(
          preset.brandColor >> 24 & 0xFF,
          0xFF,
          reason: '${preset.id} is not opaque',
        );
        expect(preset.brandColor, lessThanOrEqualTo(0xFFFFFFFF));
      }
    });

    test('preset ids are unique', () {
      final ids = PresetCatalog.all.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('search is case-insensitive and matches partial names', () {
      expect(PresetCatalog.search('netf').single.id, 'netflix');
      expect(PresetCatalog.search('NETFLIX').single.id, 'netflix');
      expect(PresetCatalog.search('').length, PresetCatalog.all.length);
    });
  });
}
