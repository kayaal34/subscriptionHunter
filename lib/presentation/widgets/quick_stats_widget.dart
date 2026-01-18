import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:subscription_tracker/core/localization/localization_helper.dart';
import 'package:subscription_tracker/core/services/notification_service.dart';
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
                        'Bildirimler',
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
        // Test Notification Button
        if (subscriptions.isNotEmpty)
          Consumer(
            builder: (context, ref, _) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final notificationService = ref.read(notificationServiceProvider);
                      
                      // İzin kontrolü (test için her zaman kontrol et)
                      final granted = await notificationService.requestNotificationPermission(
                        forceRequest: true, // Test için her zaman izin iste
                      );
                      if (!granted) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bildirim izni verilmedi'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }
                      
                      // Exact alarm izni kontrolü
                      final exactAlarmGranted = await notificationService.checkExactAlarmPermission();
                      if (!exactAlarmGranted) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tam zamanlama izni gerekli. Ayarlara yonlendiriliyorsunuz...'),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                        return;
                      }
                      
                      // Pil optimizasyonu izni (Samsung uyumluluk)
                      final batteryExempted = await notificationService.requestBatteryOptimizationExemption();
                      if (!batteryExempted) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pil optimizasyonu izni onemli (Samsung cihazlar icin)'),
                              backgroundColor: Colors.orange,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                      
                      // Test bildirimi gönder
                      await notificationService.showTestNotification();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Test bildirimi gonderildi! 5 saniye sonra ikinci bildirim gelecek.'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 5),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Hata: $e'),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.notifications_active, size: 18),
                  label: const Text('Test Bildirimi Gönder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
