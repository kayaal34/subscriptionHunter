import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../domain/subscription.dart';
import '../providers/subscription_providers.dart';
import '../widgets/subscription_card.dart';
import '../widgets/totals_header.dart';
import '../widgets/upcoming_strip.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(subscriptionsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _LoadFailure(error: error),
          data: (all) => all.isEmpty
              ? EmptyState(
                  key: const Key('home-empty-state'),
                  icon: Icons.receipt_long_outlined,
                  title: l10n.homeEmptyTitle,
                  message: l10n.homeEmptyMessage,
                  actionLabel: l10n.homeEmptyAction,
                  onAction: () => context.push(AppRoutes.add),
                )
              : const _HomeContent(),
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = ref.watch(nowProvider)();
    final visible = ref.watch(visibleSubscriptionsProvider);
    final upcoming = ref.watch(upcomingBillsProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(floating: true, title: Text(l10n.appTitle)),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child:
                TotalsHeader(
                      monthlyTotal: ref.watch(monthlyTotalProvider),
                      yearlyTotal: ref.watch(yearlyTotalProvider),
                      activeCount: ref
                          .watch(activeSubscriptionsProvider)
                          .length,
                      currencyCode: ref.watch(currencyCodeProvider),
                      hasOtherCurrencies: ref
                          .watch(secondaryCurrenciesProvider)
                          .isNotEmpty,
                    )
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: -0.08, curve: Curves.easeOutCubic),
          ),
        ),

        if (upcoming.isNotEmpty)
          SliverToBoxAdapter(
            child: UpcomingStrip(
              bills: upcoming,
            ).animate().fadeIn(delay: 90.ms, duration: 350.ms),
          ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.homeAllSubscriptions,
                    style: context.text.titleMedium,
                  ),
                ),
                const _SortMenu(),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverToBoxAdapter(
            child: TextField(
              key: const Key('home-search-field'),
              onChanged: ref.read(searchQueryProvider.notifier).set,
              decoration: InputDecoration(
                hintText: l10n.homeSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
              ),
            ),
          ),
        ),

        // A search that matches nothing used to render a blank area with no
        // explanation.
        if (visible.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 36,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.homeNoResults(ref.watch(searchQueryProvider)),
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 250.ms),
          )
        else
          SliverPadding(
            // Bottom padding clears the floating action button.
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              96,
            ),
            sliver: SliverList.separated(
              itemCount: visible.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final subscription = visible[index];
                return Dismissible(
                      // Keyed by id, not index, so dismissing one row does not
                      // make the list animate the wrong card away.
                      key: ValueKey('dismiss-${subscription.id}'),
                      direction: DismissDirection.endToStart,
                      background: const _DeleteBackground(),
                      onDismissed: (_) =>
                          _deleteWithUndo(context, ref, subscription),
                      child: SubscriptionCard(
                        key: Key('subscription-card-${subscription.id}'),
                        subscription: subscription,
                        daysAway: subscription.daysUntilNextBilling(now),
                        onTap: () =>
                            context.push(AppRoutes.detailFor(subscription.id)),
                      ),
                    )
                    .animate()
                    // Staggered, but capped: with 40 rows an uncapped delay
                    // would leave the last card fading in a second late.
                    .fadeIn(
                      delay: Duration(milliseconds: 30 * (index.clamp(0, 8))),
                      duration: 300.ms,
                    )
                    .slideY(begin: 0.12, curve: Curves.easeOutCubic);
              },
            ),
          ),
      ],
    );
  }
}

/// Deletes [subscription] and offers an undo for a few seconds.
///
/// A swipe is easy to trigger by accident, so the row is restored verbatim -
/// same id, same created date - rather than re-added as a new subscription.
Future<void> _deleteWithUndo(
  BuildContext context,
  WidgetRef ref,
  Subscription subscription,
) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final actions = ref.read(subscriptionActionsProvider);

  await actions.delete(subscription.id);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(l10n.deletedSnack(subscription.name)),
        action: SnackBarAction(
          label: l10n.actionUndo,
          onPressed: () => actions.add(subscription),
        ),
      ),
    );
}

/// Red "delete" surface revealed while swiping a card away.
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
    decoration: BoxDecoration(
      color: context.colors.errorContainer,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
    ),
    child: Icon(
      Icons.delete_outline_rounded,
      color: context.colors.onErrorContainer,
    ),
  );
}

class _SortMenu extends ConsumerWidget {
  const _SortMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(sortProvider);

    return PopupMenuButton<SubscriptionSort>(
      key: const Key('home-sort-menu'),
      initialValue: current,
      icon: const Icon(Icons.sort_rounded),
      onSelected: ref.read(sortProvider.notifier).set,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: SubscriptionSort.nextPayment,
          child: Text(l10n.detailNextPayment),
        ),
        PopupMenuItem(
          value: SubscriptionSort.priceHighToLow,
          child: Text('${l10n.fieldPrice} ↓'),
        ),
        PopupMenuItem(
          value: SubscriptionSort.priceLowToHigh,
          child: Text('${l10n.fieldPrice} ↑'),
        ),
        PopupMenuItem(
          value: SubscriptionSort.name,
          child: Text(l10n.fieldName),
        ),
      ],
    );
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: context.colors.error,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('$error', textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
