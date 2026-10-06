import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/providers/settings_providers.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../providers/subscription_providers.dart';
import '../widgets/subscription_card.dart';
import '../widgets/totals_header.dart';
import '../widgets/upcoming_timeline.dart';

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

    // Wallet order: the card due soonest is last, so it lands in front and
    // fully visible while the later ones peek out above it.
    final stack = visible.reversed.toList();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.upper(l10n.appTitle),
                            style: monoStyle(size: 12).copyWith(
                              color: context.colors.onSurfaceVariant,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        FilledButton.icon(
                          key: const Key('home-add'),
                          onPressed: () => context.push(AppRoutes.add),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 38),
                            padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: Text(l10n.actionAdd),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
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
                      nextLabel: ref.watch(upcomingBillsProvider).isEmpty
                          ? null
                          : l10n.dueLabel(
                              ref.watch(upcomingBillsProvider).first.daysAway,
                            ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const UpcomingTimeline(),
                  ],
                )
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: -0.06, curve: Curves.easeOutCubic),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.md,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
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
                const _SortMenu(),
              ],
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
            // Bottom padding clears the floating navigation bar.
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              32,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  for (var i = 0; i < stack.length; i++)
                    _Peek(
                      // Every card but the front one shows only its header.
                      peek: i < stack.length - 1,
                      child:
                          SubscriptionCard(
                                key: Key('subscription-card-${stack[i].id}'),
                                subscription: stack[i],
                                daysAway: stack[i].daysUntilNextBilling(now),
                                onTap: () => context.push(
                                  AppRoutes.detailFor(stack[i].id),
                                ),
                              )
                              .animate()
                              .fadeIn(
                                delay: Duration(
                                  milliseconds:
                                      40 * ((stack.length - 1 - i).clamp(0, 6)),
                                ),
                                duration: 320.ms,
                              )
                              .slideY(begin: 0.1, curve: Curves.easeOutCubic),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Lays a card out at only [walletCardPeek] tall while it still paints in
/// full, so the next card overlaps it like passes in a wallet.
class _Peek extends StatelessWidget {
  const _Peek({required this.peek, required this.child});

  final bool peek;
  final Widget child;

  @override
  Widget build(BuildContext context) => peek
      ? Align(
          alignment: Alignment.topCenter,
          heightFactor: walletCardPeek / walletCardHeight,
          child: child,
        )
      : child;
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
