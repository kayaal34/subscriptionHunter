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
import '../../domain/billing_calculator.dart';
import '../../domain/subscription.dart';
import '../providers/subscription_providers.dart';
import '../widgets/subscription_card.dart';

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
          SubscriptionCard(
            subscription: subscription,
            daysAway: subscription.daysUntilNextBilling(now),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.06),

          const SizedBox(height: AppSpacing.xl),
          _PaymentDots(subscription: subscription, now: now),
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
            style: monoStyle(size: 13),
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
            style: monoStyle(size: 17),
          ),
        ),
      ],
    ),
  );
}

/// Twelve months around today: paid, the next charge, and those still to come.
class _PaymentDots extends StatelessWidget {
  const _PaymentDots({required this.subscription, required this.now});

  final Subscription subscription;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final today = DateUtils.dateOnly(now);
    final first = DateTime(today.year, today.month - 6, 1);
    final last = DateTime(today.year, today.month + 6, 0);
    final charges = BillingCalculator.occurrencesInRange(
      anchor: subscription.anchorDate,
      cycle: subscription.billingCycle,
      rangeStart: first,
      rangeEnd: last,
      endDate: subscription.endDate,
    );
    final next = subscription.nextBillingDate(now);
    final label = DateFormat('MMMMM', context.localeName);

    Widget dot(DateTime month) {
      final inMonth = charges.where(
        (d) => d.year == month.year && d.month == month.month,
      );
      Color? fill;
      Border? border;
      if (inMonth.isEmpty) {
        border = Border.all(color: colors.outlineVariant);
      } else if (inMonth.any((d) => d == next)) {
        border = Border.all(color: colors.primary, width: 2);
      } else if (inMonth.first.isBefore(today)) {
        fill = colors.primary;
      } else {
        border = Border.all(color: colors.outline, width: 1.5);
      }
      return Column(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fill,
              border: border,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.upper(label.format(month)),
            style: monoStyle(size: 9.5).copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < 12; i++)
          dot(DateTime(today.year, today.month - 6 + i, 1)),
      ],
    ).animate().fadeIn(delay: 60.ms, duration: 320.ms);
  }
}
