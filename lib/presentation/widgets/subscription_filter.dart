import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subscription_tracker/core/localization/localization_helper.dart';
import 'package:subscription_tracker/presentation/providers/theme_provider.dart';

/// Filter widget for searching and sorting subscriptions
class SubscriptionFilter extends ConsumerWidget {
  const SubscriptionFilter({
    Key? key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.sortBy,
    required this.onSortChanged,
  }) : super(key: key);

  final String searchQuery;
  final Function(String) onSearchChanged;
  final String sortBy; // 'name', 'cost', 'date'
  final Function(String) onSortChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final l10n = LocalizationHelper(language);

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search field
          TextField(
            decoration: InputDecoration(
              hintText: l10n.search,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),
          // Sort options
          Row(
            children: [
              Text(
                l10n.sortBy, // Localized string for 'Sort By'
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: sortBy,
                  items: [
                    DropdownMenuItem(
                      value: 'name',
                      child: Text(l10n.subscriptionName),
                    ),
                    DropdownMenuItem(
                      value: 'cost',
                      child: Text(l10n.cost),
                    ),
                    DropdownMenuItem(
                      value: 'date',
                      child: Text(l10n.startDate),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onSortChanged(value);
                    }
                  },
                  isExpanded: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
