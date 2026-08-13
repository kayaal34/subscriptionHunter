import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../providers/subscription_providers.dart';
import 'subscription_avatar.dart';

/// Horizontally scrolling "what is about to be charged" strip.
class UpcomingStrip extends StatelessWidget {
  const UpcomingStrip({required this.bills, super.key});

  final List<UpcomingBill> bills;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Text(l10n.homeUpcoming, style: context.text.titleMedium),
        ),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: bills.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final bill = bills[index];
              return SizedBox(
                width: 168,
                child: SoftCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  onTap: () =>
                      context.push(AppRoutes.detailFor(bill.subscription.id)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SubscriptionAvatar(
                            subscription: bill.subscription,
                            size: 34,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              bill.subscription.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.labelLarge,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            MoneyFormatter.format(
                              amount: bill.subscription.price,
                              currencyCode: bill.subscription.currencyCode,
                              localeName: context.localeName,
                            ),
                            style: context.text.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            l10n.dueLabel(bill.daysAway),
                            style: context.text.labelSmall?.copyWith(
                              color: bill.daysAway <= 3
                                  ? AppPalette.warning
                                  : context.colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
