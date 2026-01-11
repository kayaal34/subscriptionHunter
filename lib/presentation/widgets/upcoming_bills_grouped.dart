import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:subscription_tracker/core/constants/currencies.dart';
import 'package:subscription_tracker/domain/entities/subscription.dart';

class UpcomingBillsGrouped extends ConsumerWidget {

  const UpcomingBillsGrouped({
    required this.subscriptions,
    Key? key,
  }) : super(key: key);
  final List<Subscription> subscriptions;

  /// Group subscriptions by upcoming date
  Map<String, List<Subscription>> _groupByDate(List<Subscription> subs) {
    final groups = <String, List<Subscription>>{};

    for (final sub in subs) {
      final daysUntil = sub.getDaysUntilBilling();
      
      String groupKey;
      if (daysUntil == 0) {
        groupKey = '🔴 Today';
      } else if (daysUntil == 1) {
        groupKey = '🟠 Tomorrow';
      } else if (daysUntil <= 7) {
        groupKey = '🟡 This Week';
      } else if (daysUntil <= 14) {
        groupKey = '🟢 Next 2 Weeks';
      } else {
        final nextBilling = sub.getNextBillingDate();
        groupKey = DateFormat('MMM d').format(nextBilling);
      }

      groups.putIfAbsent(groupKey, () => []).add(sub);
    }

    // Sort groups by due date
    final sortedGroups = <String, List<Subscription>>{};
    final groupOrder = ['🔴 Today', '🟠 Tomorrow', '🟡 This Week', '🟢 Next 2 Weeks'];
    
    for (final key in groupOrder) {
      if (groups.containsKey(key)) {
        sortedGroups[key] = groups[key]!;
      }
    }

    // Add remaining groups sorted by date
    final remainingKeys = groups.keys.where((k) => !groupOrder.contains(k)).toList()
      ..sort();
    for (final key in remainingKeys) {
      sortedGroups[key] = groups[key]!;
    }

    return sortedGroups;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (subscriptions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No upcoming bills',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'You\'re all caught up!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final groupedBills = _groupByDate(subscriptions);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groupedBills.length,
      itemBuilder: (context, index) {
        final groupKey = groupedBills.keys.elementAt(index);
        final bills = groupedBills[groupKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                groupKey,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...bills.asMap().entries.map((entry) {
              final sub = entry.value;
              final daysUntil = sub.getDaysUntilBilling();
              
              return _BillCard(
                subscription: sub,
                daysUntil: daysUntil,
                onTap: () {
                  // Handle bill tap
                },
              );
            }),
          ],
        );
      },
    );
  }
}

class _BillCard extends ConsumerWidget {

  const _BillCard({
    required this.subscription,
    required this.daysUntil,
    required this.onTap,
    Key? key,
  }) : super(key: key);
  final Subscription subscription;
  final int daysUntil;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayPrice = CurrencyConverter.convert(
      amount: subscription.cost,
      fromCurrency: subscription.currency,
      toCurrency: 'TRY',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Logo/Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getColorByDays(daysUntil),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      subscription.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Title and Days
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        daysUntil == 0
                            ? 'Due today'
                            : daysUntil == 1
                                ? 'Tomorrow'
                                : 'in $daysUntil days',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${displayPrice.toStringAsFixed(2)} ₺',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getColorByDays(daysUntil),
                      ),
                    ),
                    if (subscription.currency != 'TRY')
                      Text(
                        '${subscription.cost.toStringAsFixed(2)} ${subscription.currency}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorByDays(int days) {
    if (days == 0) return Colors.red;
    if (days <= 2) return Colors.orange;
    if (days <= 7) return Colors.amber;
    return Colors.green;
  }
}
