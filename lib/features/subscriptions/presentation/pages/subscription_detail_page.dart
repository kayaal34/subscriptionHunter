import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../../../shared/widgets/subscription_logo.dart';
import '../../domain/billing_calculator.dart';
import '../../domain/subscription.dart';
import '../providers/subscription_providers.dart';

class SubscriptionDetailPage extends ConsumerWidget {
  const SubscriptionDetailPage({required this.id, super.key});

  final String id;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage(subscription.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const Key('confirm-delete'),
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(subscriptionActionsProvider).delete(subscription.id);
    if (!context.mounted) return;

    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.deletedSnack(subscription.name))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final subscription = ref.watch(subscriptionByIdProvider(id));

    // Deleting pops this route, but one frame can still rebuild with the row
    // already gone.
    if (subscription == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    final now = ref.watch(nowProvider)();
    final next = subscription.nextBillingDate(now);
    final previous = BillingCalculator.previousBillingDate(
      anchor: subscription.anchorDate,
      cycle: subscription.billingCycle,
      from: now,
    );
    final dateFormat = DateFormat.yMMMMd(context.localeName);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            key: const Key('detail-edit'),
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                context.push('${AppRoutes.detailFor(subscription.id)}/edit'),
          ),
          IconButton(
            key: const Key('detail-delete'),
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context, ref, subscription),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          Center(
            child: Hero(
              tag: 'logo-${subscription.id}',
              child: SubscriptionLogo(
                monogram: subscription.name.isEmpty
                    ? '?'
                    : subscription.name.substring(0, 1).toUpperCase(),
                brandColor: subscription.brandColor,
                assetPath: subscription.logoAsset,
                logoUrl: subscription.logoUrl,
                size: 88,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            subscription.name,
            textAlign: TextAlign.center,
            style: context.text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${MoneyFormatter.format(amount: subscription.price, currencyCode: subscription.currencyCode, localeName: context.localeName)} · ${subscription.billingCycle.label(l10n)}',
            textAlign: TextAlign.center,
            style: context.text.bodyLarge?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          SoftCard(
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.event_available_outlined,
                  label: l10n.detailNextPayment,
                  value: dateFormat.format(next),
                  highlight: l10n.dueLabel(
                    subscription.daysUntilNextBilling(now),
                  ),
                ),
                const Divider(height: AppSpacing.xl),
                _DetailRow(
                  icon: Icons.history_rounded,
                  label: l10n.detailLastPayment,
                  value: previous == null
                      ? l10n.detailNeverBilled
                      : dateFormat.format(previous),
                ),
                const Divider(height: AppSpacing.xl),
                _DetailRow(
                  icon: Icons.play_circle_outline,
                  label: l10n.detailStarted,
                  value: dateFormat.format(subscription.anchorDate),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.08),

          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _CostTile(
                  label: l10n.detailCostPerMonth,
                  amount: subscription.monthlyCost,
                  currencyCode: subscription.currencyCode,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _CostTile(
                  label: l10n.detailCostPerYear,
                  amount: subscription.yearlyCost,
                  currencyCode: subscription.currencyCode,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 80.ms, duration: 320.ms),

          if (subscription.notes case final notes? when notes.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.detailNotes, style: context.text.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(notes, style: context.text.bodyMedium),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? highlight;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 20, color: context.colors.onSurfaceVariant),
      const SizedBox(width: AppSpacing.md),
      Expanded(
        child: Text(
          label,
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (highlight != null)
            Text(
              highlight!,
              style: context.text.labelSmall?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    ],
  );
}

class _CostTile extends StatelessWidget {
  const _CostTile({
    required this.label,
    required this.amount,
    required this.currencyCode,
  });

  final String label;
  final double amount;
  final String currencyCode;

  @override
  Widget build(BuildContext context) => SoftCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.text.labelSmall?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            MoneyFormatter.format(
              amount: BillingCalculator.roundMoney(amount),
              currencyCode: currencyCode,
              localeName: context.localeName,
            ),
            style: context.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}
