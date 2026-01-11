import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:subscription_tracker/core/localization/localization_helper.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';
import 'package:subscription_tracker/presentation/providers/theme_provider.dart';

/// Quick statistics widget showing key metrics
class QuickStatsWidget extends ConsumerWidget {
  const QuickStatsWidget({
    Key? key,
    required this.subscriptions,
  }) : super(key: key);

  final List<Subscription> subscriptions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final l10n = LocalizationHelper(language);

    final monthlyTotal = subscriptions.fold<double>(
      0,
      (sum, sub) => sum + (sub.billingCycle == BillingCycle.monthly ? sub.cost : sub.cost / 12),
    );

    final annualTotal = subscriptions.fold<double>(
      0,
      (sum, sub) => sum + (sub.billingCycle == BillingCycle.yearly ? sub.cost : sub.cost * 12),
    );

    return Column(
      children: [
        // Stats Cards
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hızlı İstatistikler',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: l10n.totalMonthly,
                      value: '₺${monthlyTotal.toStringAsFixed(2)}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: l10n.totalAnnual,
                      value: '₺${annualTotal.toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Abonelik Sayısı',
                      value: '${subscriptions.length}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Ortalama Maliyet',
                      value: '₺${(monthlyTotal / (subscriptions.isEmpty ? 1 : subscriptions.length)).toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Notification Toggle in Stats Area
        if (subscriptions.isNotEmpty)
          Consumer(
            builder: (context, ref, _) {
              final appSettings = Hive.box('app_settings');
              final phoneNotifEnabled = appSettings.get('phoneNotifEnabled', defaultValue: true) as bool;
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E5EA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications, color: Color(0xFF007AFF), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bildirim Bildirimleri',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Switch(
                      value: phoneNotifEnabled,
                      onChanged: (val) {
                        appSettings.put('phoneNotifEnabled', val);
                      },
                      activeThumbColor: const Color(0xFF007AFF),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      );
}
